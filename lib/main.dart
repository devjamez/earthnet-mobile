import 'dart:async';

import 'package:flutter/material.dart';

import 'src/alarm.dart';
import 'src/backoff.dart';
import 'src/countdown.dart';
import 'src/foreground_service.dart';
import 'src/geo.dart';
import 'src/geocode.dart';
import 'src/identity.dart';
import 'src/location.dart';
import 'src/observation_sender.dart';
import 'src/proto/earthnet.pb.dart';
import 'src/relay_connection.dart';
import 'src/rust/frb_generated.dart';
import 'src/sensor.dart';
import 'src/verify.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init(); // load the shared Rust core (detection bridge)
  runApp(const EarthNetApp());
}

class EarthNetApp extends StatelessWidget {
  const EarthNetApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EarthNet',
    theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
    home: const AlertPage(),
  );
}

/// An incoming event annotated with verification, epicenter, and distance.
/// The countdown is recomputed live from the event's origin time.
class ReceivedAlert {
  ReceivedAlert({
    required this.event,
    required this.verified,
    required this.epiLat,
    required this.epiLon,
    required this.distanceKm,
    required this.userLat,
    required this.userLon,
  });

  final ConfirmedEvent event;
  final bool verified;
  final double epiLat;
  final double epiLon;
  final double distanceKm;
  final double userLat;
  final double userLon;

  /// Reverse-geocoded epicenter place name; filled in asynchronously.
  String? placeName;

  double get leadSeconds => sWaveLeadSeconds(event, userLat, userLon);
}

// Demo hooks: `--dart-define=AUTOCONNECT=true --dart-define=RELAY_URL=...`
const _autoConnect = bool.fromEnvironment('AUTOCONNECT');
const _defaultRelayUrl = String.fromEnvironment(
  'RELAY_URL',
  defaultValue: 'ws://192.168.1.66:8090/subscribe',
);

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final _url = TextEditingController(text: _defaultRelayUrl);
  double _lat = DeviceLocation.fallback.lat;
  double _lon = DeviceLocation.fallback.lon;
  bool _gps = false;
  final List<ReceivedAlert> _alerts = [];
  RelaySubscription? _sub;
  Timer? _ticker;
  Timer? _reconnect;
  bool _wantConnected = false;
  int _backoff = 1;
  String _status = 'disconnected';

  // On-device detection (Rust STA/LTA via flutter_rust_bridge).
  final SensorDetector _detector = SensorDetector();
  bool _sensing = false;
  double _staLta = 0;
  bool _pwave = false;
  ObservationSender? _sender;
  DateTime? _lastSent;
  String _sensorMsg = '';

  @override
  void initState() {
    super.initState();
    // Live countdown: rebuild every second so lead times tick down.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Load (or create) this phone's stable anonymous signing identity.
    Identity.loadOrCreate().then((id) {
      if (mounted) setState(() => _sender = ObservationSender(id));
    });
    if (_autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
    }
  }

  /// User intent to be connected; (re)opens the socket and keeps it open.
  Future<void> _connect() async {
    _wantConnected = true;
    await _open();
  }

  Future<void> _open() async {
    if (!_wantConnected) return;
    _reconnect?.cancel();
    await _sub?.close();
    setState(() => _status = 'connecting…');
    final location = await DeviceLocation.current();
    _lat = location.lat;
    _lon = location.lon;
    _gps = location.gps;
    final sub = RelaySubscription.connect(Uri.parse(_url.text));
    _sub = sub;
    try {
      await sub.ready; // throws on connection failure
    } catch (_) {
      _scheduleReconnect();
      return;
    }
    if (!_wantConnected) {
      await sub.close();
      return;
    }
    await ForegroundService.start();
    _backoff = 1; // healthy connection resets backoff
    setState(() => _status = 'connected');
    sub.events.listen(
      (event) async {
        final verified = await verifyConfirmedEvent(event);
        final (epiLat, epiLon) = decodeGeohash(event.epicenter.geohash);
        final alert = ReceivedAlert(
          event: event,
          verified: verified,
          epiLat: epiLat,
          epiLon: epiLon,
          distanceKm: haversineKm(epiLat, epiLon, _lat, _lon),
          userLat: _lat,
          userLon: _lon,
        );
        if (!mounted) return;
        if (verified && alert.leadSeconds > 0) {
          Alarm.trigger();
        }
        setState(() => _alerts.insert(0, alert));
        // Reverse-geocode the (public) epicenter in the background.
        ReverseGeocode.placeName(epiLat, epiLon).then((name) {
          if (name != null && mounted) {
            setState(() => alert.placeName = name);
          }
        });
      },
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: true,
    );
  }

  /// Reconnect with exponential backoff while the user still wants connection.
  void _scheduleReconnect() {
    if (!mounted) return;
    if (!_wantConnected) {
      setState(() => _status = 'disconnected');
      return;
    }
    final delay = _backoff;
    setState(() => _status = 'reconnecting in ${delay}s…');
    _reconnect?.cancel();
    _reconnect = Timer(Duration(seconds: delay), _open);
    _backoff = nextBackoff(_backoff);
  }

  Future<void> _disconnect() async {
    _wantConnected = false;
    _reconnect?.cancel();
    await _sub?.close();
    await ForegroundService.stop();
    if (mounted) setState(() => _status = 'disconnected');
  }

  /// Toggle on-device P-wave detection from the accelerometer.
  Future<void> _toggleSensor() async {
    if (_sensing) {
      await _detector.stop();
      setState(() {
        _sensing = false;
        _staLta = 0;
        _pwave = false;
        _sensorMsg = '';
      });
      return;
    }
    // Attach picks to the real device location.
    final loc = await DeviceLocation.current();
    _lat = loc.lat;
    _lon = loc.lon;
    _gps = loc.gps;
    _detector.start((ratio, pick, peakG) {
      if (!mounted) return;
      setState(() {
        _staLta = ratio;
        _pwave = pick;
      });
      if (pick) _maybeSend(peakG);
    });
    setState(() => _sensing = true);
  }

  /// On a P-wave pick, sign + POST an Observation to the node (rate-limited).
  Future<void> _maybeSend(double peakG) async {
    final sender = _sender;
    if (sender == null) return;
    final now = DateTime.now();
    if (_lastSent != null &&
        now.difference(_lastSent!) < const Duration(seconds: 30)) {
      return; // cooldown: one observation per detection burst
    }
    _lastSent = now;
    final host = Uri.tryParse(_url.text)?.host ?? '';
    if (host.isEmpty) return;
    final code = await sender.send(
      nodeUrl: 'http://$host:8080/observations',
      lat: _lat,
      lon: _lon,
      staLtaRatio: _staLta,
      estimatedPgaG: peakG,
    );
    if (mounted) {
      setState(() => _sensorMsg =
          code == 202 ? '📡 observación enviada (HTTP 202)' : '✗ envío falló ($code)');
    }
  }

  @override
  void dispose() {
    _wantConnected = false;
    _ticker?.cancel();
    _reconnect?.cancel();
    _detector.stop();
    _sub?.close();
    ForegroundService.stop();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EarthNet — alerta temprana')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _url,
                    decoration: const InputDecoration(labelText: 'Relay WebSocket'),
                  ),
                ),
                const SizedBox(width: 8),
                _wantConnected
                    ? OutlinedButton(onPressed: _disconnect, child: const Text('Disconnect'))
                    : FilledButton(onPressed: _connect, child: const Text('Connect')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(alignment: Alignment.centerLeft, child: Text('Status: $_status')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tu ubicación: ${_lat.toStringAsFixed(3)}, ${_lon.toStringAsFixed(3)}'
                ' (${_gps ? "GPS" : "demo"})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ),
          // On-device detection panel (Rust STA/LTA via flutter_rust_bridge).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _toggleSensor,
                      icon: Icon(_sensing ? Icons.sensors : Icons.sensors_off),
                      label: Text(_sensing ? 'Sensor ON' : 'Sensor OFF'),
                    ),
                    const SizedBox(width: 12),
                    if (_sensing)
                      Expanded(
                        child: Text(
                          _pwave
                              ? '⚠ ONDA P DETECTADA (STA/LTA ${_staLta.toStringAsFixed(1)})'
                              : 'STA/LTA ${_staLta.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _pwave ? Colors.red : Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_sensorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _sensorMsg,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _alerts.isEmpty
                ? const Center(child: Text('Esperando sismos…'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _alerts.length,
                    itemBuilder: (context, i) => _AlertCard(_alerts[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard(this.alert);
  final ReceivedAlert alert;

  static String _lat(double v) => '${v.abs().toStringAsFixed(2)}°${v >= 0 ? 'N' : 'S'}';
  static String _lon(double v) => '${v.abs().toStringAsFixed(2)}°${v >= 0 ? 'E' : 'W'}';

  @override
  Widget build(BuildContext context) {
    final lead = alert.leadSeconds;
    final incoming = lead > 0;
    final color = incoming ? Colors.red : Colors.grey.shade600;
    final m = alert.event.magnitude;

    return Card(
      color: incoming ? Colors.red.withValues(alpha: 0.08) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big live countdown
            SizedBox(
              width: 96,
              child: Column(
                children: [
                  Text(
                    incoming ? '${lead.ceil()}' : '—',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    incoming ? 'seg. para\nla onda S' : 'onda S\nya llegó',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m > 0 ? 'Magnitud ${m.toStringAsFixed(1)}' : 'Magnitud —',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        alert.verified ? Icons.verified : Icons.gpp_bad,
                        size: 18,
                        color: alert.verified ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (alert.placeName != null)
                    Text(
                      'Epicentro: cerca de ${alert.placeName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  Text(
                    '${_lat(alert.epiLat)}, ${_lon(alert.epiLon)}',
                    style: TextStyle(
                      fontSize: alert.placeName != null ? 12 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'A ${alert.distanceKm.toStringAsFixed(0)} km de vos',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
