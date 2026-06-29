import 'dart:async';

import 'package:flutter/material.dart';

import 'src/alarm.dart';
import 'src/backoff.dart';
import 'src/countdown.dart';
import 'src/foreground_service.dart';
import 'src/geo.dart';
import 'src/geocode.dart';
import 'src/identity.dart';
import 'src/intensity.dart';
import 'src/location.dart';
import 'src/observation_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/proto/earthnet.pb.dart';
import 'src/pulse_indicator.dart';
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

  /// Expected shaking at the user's location (informational; attenuates with
  /// distance). The alert that saves lives is the lead-time countdown, not this.
  double get mmiHere => expectedMmi(event.magnitude, distanceKm);

  /// Expected shaking near the epicenter (always stronger than [mmiHere]).
  double get mmiEpicenter => expectedMmi(event.magnitude, 0);
}

// Demo hooks: `--dart-define=AUTOCONNECT=true --dart-define=RELAY_URL=...`
// Drop an alert this many seconds after its S-wave has passed (keeps the list
// to what's actionable; old expired alerts auto-clear).
const _alertLingerSeconds = 60;
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
  // Filter out alerts not expected to be felt here (off by default for testing).
  bool _filterByIntensity = false;

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
    // Live countdown + auto-clear: rebuild every second so lead times tick down,
    // and drop alerts whose S-wave passed more than _alertLingerSeconds ago.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _alerts.removeWhere((a) => a.leadSeconds < -_alertLingerSeconds);
      });
    });
    // Load (or create) this phone's stable anonymous signing identity.
    Identity.loadOrCreate().then((id) {
      if (mounted) setState(() => _sender = ObservationSender(id));
    });
    // Restore saved settings (relay URL + intensity filter).
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        final u = p.getString('relay_url');
        if (u != null && u.isNotEmpty) _url.text = u;
        _filterByIntensity = p.getBool('filter_by_intensity') ?? false;
      });
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
        // Intensity filter: skip events not expected to be felt here. The
        // lead-time countdown is the life-saving signal; this only hides shaking
        // too weak to matter at the user's location.
        if (_filterByIntensity && alert.mmiHere < kFeltMmi) return;
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

  /// Settings dialog: relay URL + intensity filter, both persisted.
  Future<void> _openSettings() async {
    final ctrl = TextEditingController(text: _url.text);
    var filter = _filterByIntensity;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Ajustes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Relay WebSocket',
                  hintText: 'ws://host:8090/subscribe',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sólo alertas que me afectan'),
                subtitle: const Text('Oculta sismos que no se sentirían aquí'),
                value: filter,
                onChanged: (v) => setLocal(() => filter = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final newUrl = ctrl.text.trim();
    final urlChanged = newUrl.isNotEmpty && newUrl != _url.text;
    setState(() {
      if (urlChanged) _url.text = newUrl;
      _filterByIntensity = filter;
    });
    final prefs = await SharedPreferences.getInstance();
    if (urlChanged) await prefs.setString('relay_url', newUrl);
    await prefs.setBool('filter_by_intensity', filter);
    if (urlChanged && _wantConnected) await _open(); // reconnect with new URL
  }

  /// Status label, color, animate flag and icon for the central indicator.
  (String, Color, bool, IconData) _indicatorState() {
    if (!_wantConnected) {
      return ('Desconectada · tocá Conectar', Colors.grey, false, Icons.power_settings_new);
    }
    if (_status == 'connected') {
      if (_sensing && _pwave) {
        return ('⚠ Procesando onda P', Colors.deepOrange, true, Icons.graphic_eq);
      }
      final label = _sensing ? 'Activa · sensor + escuchando' : 'Activa · escuchando';
      return (label, Colors.green, true, Icons.graphic_eq);
    }
    // connecting / reconnecting / transient error while we want to be connected
    return ('Conectando…', Colors.amber.shade800, true, Icons.wifi_tethering);
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
      appBar: AppBar(
        title: const Text('EarthNet — alerta temprana'),
        actions: [
          if (_alerts.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar alertas',
              onPressed: () => setState(_alerts.clear),
              icon: const Icon(Icons.clear_all),
            ),
          IconButton(
            tooltip: _sensing ? 'Sensor activo' : 'Activar sensor',
            onPressed: _toggleSensor,
            color: _sensing ? (_pwave ? Colors.deepOrange : Colors.green) : null,
            icon: Icon(_sensing ? Icons.sensors : Icons.sensors_off),
          ),
          IconButton(
            tooltip: 'Ajustes',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _alerts.isEmpty ? _statusView() : _alertList(),
    );
  }

  /// Central "alive / listening" view shown while there are no active alerts.
  Widget _statusView() {
    final (label, color, active, icon) = _indicatorState();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PulseIndicator(color: color, active: active, icon: icon),
            const SizedBox(height: 28),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu ubicación: ${_lat.toStringAsFixed(3)}, ${_lon.toStringAsFixed(3)}'
              ' (${_gps ? "GPS" : "demo"})',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            if (_sensing && _staLta > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'STA/LTA ${_staLta.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            if (_sensorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _sensorMsg,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            const SizedBox(height: 28),
            _wantConnected
                ? OutlinedButton.icon(
                    onPressed: _disconnect,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Desconectar'),
                  )
                : FilledButton.icon(
                    onPressed: _connect,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Conectar'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _alertList() => ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _alerts.length,
        itemBuilder: (context, i) => _AlertCard(_alerts[i]),
      );
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
              width: 124,
              child: Column(
                children: [
                  Text(
                    incoming ? '${lead.ceil()}' : '—',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: color,
                    ),
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
                  const SizedBox(height: 4),
                  // Informational: expected shaking here (attenuates with
                  // distance) vs near the epicenter. Not the alert trigger.
                  Text(
                    'Intensidad aquí: ${intensityText(alert.mmiHere)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: alert.mmiHere >= kFeltMmi
                          ? Colors.deepOrange
                          : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'cerca del epicentro: ${intensityText(alert.mmiEpicenter)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
