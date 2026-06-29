import 'package:flutter/material.dart';

import 'src/alarm.dart';
import 'src/countdown.dart';
import 'src/foreground_service.dart';
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

/// An incoming event annotated with verification + local S-wave countdown.
class ReceivedAlert {
  ReceivedAlert(this.event, this.verified, this.leadSeconds);
  final ConfirmedEvent event;
  final bool verified;
  final double leadSeconds;
}

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

// Demo hooks: `--dart-define=AUTOCONNECT=true --dart-define=RELAY_URL=...`
const _autoConnect = bool.fromEnvironment('AUTOCONNECT');
const _defaultRelayUrl =
    String.fromEnvironment('RELAY_URL', defaultValue: 'ws://10.0.2.2:8090/subscribe');

class _AlertPageState extends State<AlertPage> {
  final _url = TextEditingController(text: _defaultRelayUrl);

  @override
  void initState() {
    super.initState();
    if (_autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
    }
  }
  // Device location, resolved on connect (falls back to Santiago).
  double _lat = DeviceLocation.fallback.lat;
  double _lon = DeviceLocation.fallback.lon;
  final List<ReceivedAlert> _alerts = [];
  RelaySubscription? _sub;
  String _status = 'disconnected';

  Future<void> _connect() async {
    await _sub?.close();
    setState(() => _status = 'connecting…');
    final location = await DeviceLocation.current();
    _lat = location.lat;
    _lon = location.lon;
    final sub = RelaySubscription.connect(Uri.parse(_url.text));
    _sub = sub;
    await ForegroundService.start(); // keep the socket alive with screen off
    setState(() => _status = 'connected');
    sub.events.listen(
      (event) async {
        final verified = await verifyConfirmedEvent(event);
        final lead = sWaveLeadSeconds(event, _lat, _lon);
        if (!mounted) return;
        // Multimodal alarm only for a verified, still-approaching quake.
        if (verified && lead > 0) {
          Alarm.trigger();
        }
        setState(() => _alerts.insert(0, ReceivedAlert(event, verified, lead)));
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
    _sub?.close();
    ForegroundService.stop();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EarthNet — early warning')),
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
                ? const Center(child: Text('Waiting for events…'))
                : ListView.builder(
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

  @override
  Widget build(BuildContext context) {
    final lead = alert.leadSeconds;
    final incoming = lead > 0;
    final color = incoming ? Colors.red : Colors.grey;
    return Card(
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(
          alert.verified ? Icons.verified : Icons.gpp_bad,
          color: alert.verified ? Colors.green : Colors.red,
        ),
        title: Text(
          'M${alert.event.magnitude.toStringAsFixed(1)}  •  ${alert.event.evidence.name}',
        ),
        subtitle: Text(
          incoming ? 'S-wave in ${lead.toStringAsFixed(0)} s' : 'S-wave already arrived',
          style: TextStyle(
            color: color,
            fontWeight: incoming ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(alert.verified ? 'verified' : 'UNVERIFIED'),
      ),
    );
  }
}
