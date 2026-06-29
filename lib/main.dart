import 'dart:async';

import 'package:flutter/material.dart';

import 'src/alarm.dart';
import 'src/countdown.dart';
import 'src/foreground_service.dart';
import 'src/geo.dart';
import 'src/geocode.dart';
import 'src/location.dart';
import 'src/proto/earthnet.pb.dart';
import 'src/relay_connection.dart';
import 'src/verify.dart';

void main() => runApp(const EarthNetApp());

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
const _defaultRelayUrl =
    String.fromEnvironment('RELAY_URL', defaultValue: 'ws://192.168.1.66:8090/subscribe');

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final _url = TextEditingController(text: _defaultRelayUrl);
  double _lat = DeviceLocation.fallback.lat;
  double _lon = DeviceLocation.fallback.lon;
  final List<ReceivedAlert> _alerts = [];
  RelaySubscription? _sub;
  Timer? _ticker;
  String _status = 'disconnected';

  @override
  void initState() {
    super.initState();
    // Live countdown: rebuild every second so lead times tick down.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    if (_autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
    }
  }

  Future<void> _connect() async {
    await _sub?.close();
    setState(() => _status = 'connecting…');
    final location = await DeviceLocation.current();
    _lat = location.lat;
    _lon = location.lon;
    final sub = RelaySubscription.connect(Uri.parse(_url.text));
    _sub = sub;
    await ForegroundService.start();
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
      onError: (Object e) {
        if (mounted) setState(() => _status = 'error: $e');
      },
      onDone: () {
        if (mounted) setState(() => _status = 'disconnected');
      },
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
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
                FilledButton(onPressed: _connect, child: const Text('Connect')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(alignment: Alignment.centerLeft, child: Text('Status: $_status')),
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
