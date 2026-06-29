import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fixnum/fixnum.dart';

import 'geo.dart';
import 'identity.dart';
import 'proto/earthnet.pb.dart';

const _domainObservation = 'earthnet-obs-v1';

/// Builds, Ed25519-signs and POSTs a PHONE Observation to a node's
/// `/observations` endpoint — making the phone a contributing sensor.
class ObservationSender {
  ObservationSender(this.identity);

  final Identity identity;
  final _rng = Random.secure();

  /// Returns the node's HTTP status (202 = accepted), or -1 on failure.
  Future<int> send({
    required String nodeUrl,
    required double lat,
    required double lon,
    required double staLtaRatio,
    required double estimatedPgaG,
  }) async {
    // IMPORTANT: only set non-default fields. proto3 (prost, the node's decoder)
    // omits default-valued scalars; Dart protobuf would serialize an explicitly
    // set 0.0, breaking the canonical bytes the signature is verified against.
    final obs = Observation()
      ..protocolVersion = 1
      ..observationId = List<int>.generate(16, (_) => _rng.nextInt(256))
      ..pubkey = identity.publicKeyBytes
      ..sourceType = SourceType.SOURCE_TYPE_PHONE
      ..capturedAtNs =
          Int64(DateTime.now().toUtc().microsecondsSinceEpoch) * Int64(1000)
      ..clockUncertMs = 100
      ..location = (Location()
        ..geohash = encodeGeohash(lat, lon, 7)
        ..precisionM = 76)
      ..pWaveDetected = true;
    if (staLtaRatio != 0) obs.staLtaRatio = staLtaRatio;
    if (estimatedPgaG != 0) obs.estimatedPga = estimatedPgaG;

    // signature over: domain || deterministic_encode(obs with empty signature)
    final payload = <int>[
      ...utf8.encode(_domainObservation),
      ...obs.writeToBuffer(),
    ];
    obs.signature = await identity.sign(payload);

    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse(nodeUrl));
      req.headers.contentType = ContentType('application', 'octet-stream');
      req.add(obs.writeToBuffer());
      final resp = await req.close();
      await resp.drain<void>();
      return resp.statusCode;
    } catch (_) {
      return -1;
    } finally {
      client.close();
    }
  }
}
