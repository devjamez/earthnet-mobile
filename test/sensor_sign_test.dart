import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:earthnet_mobile/src/geo.dart';
import 'package:earthnet_mobile/src/identity.dart';
import 'package:earthnet_mobile/src/proto/earthnet.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _domainObservation = 'earthnet-obs-v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('geohash encode round-trips with decode', () {
    final g = encodeGeohash(-21.0, -69.6, 7);
    final (lat, lon) = decodeGeohash(g);
    expect(lat, closeTo(-21.0, 0.01));
    expect(lon, closeTo(-69.6, 0.01));
  });

  test('identity is stable across loads', () async {
    SharedPreferences.setMockInitialValues({});
    final a = await Identity.loadOrCreate();
    final b = await Identity.loadOrCreate();
    expect(a.publicKeyBytes, b.publicKeyBytes);
    expect(a.publicKeyBytes.length, 32);
  });

  test('a signed Observation verifies under the node scheme', () async {
    SharedPreferences.setMockInitialValues({});
    final id = await Identity.loadOrCreate();
    final obs = Observation()
      ..protocolVersion = 1
      ..observationId = List<int>.filled(16, 7)
      ..pubkey = id.publicKeyBytes
      ..sourceType = SourceType.SOURCE_TYPE_PHONE
      ..capturedAtNs = Int64(1700000000) * Int64(1000000000)
      ..clockUncertMs = 100
      ..location = (Location()
        ..geohash = '66jd2'
        ..precisionM = 76)
      ..staLtaRatio = 9.0
      ..pWaveDetected = true;

    final payload = <int>[
      ...utf8.encode(_domainObservation),
      ...obs.writeToBuffer(),
    ];
    obs.signature = await id.sign(payload);

    // verify exactly as the node does: domain || encode(obs, signature empty)
    final bare = obs.deepCopy()..clearSignature();
    final vpayload = <int>[
      ...utf8.encode(_domainObservation),
      ...bare.writeToBuffer(),
    ];
    final pk = SimplePublicKey(id.publicKeyBytes, type: KeyPairType.ed25519);
    final ok = await Ed25519()
        .verify(vpayload, signature: Signature(obs.signature, publicKey: pk));

    expect(ok, isTrue);
    expect(obs.signature.length, 64);
  });
}
