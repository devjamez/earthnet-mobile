import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'proto/earthnet.pb.dart';

const _domainConfirmedEvent = 'earthnet-evt-v1';

final _ed25519 = Ed25519();

/// Verifies a [ConfirmedEvent]'s Ed25519 signature using the EarthNet scheme:
/// signature over `domain || deterministic_encode(event with empty signature)`.
///
/// The node never trusts an event it cannot verify; neither should the client.
Future<bool> verifyConfirmedEvent(ConfirmedEvent event) async {
  if (event.pubkey.length != 32 || event.signature.length != 64) {
    return false;
  }
  final bare = event.deepCopy()..clearSignature();
  final payload = <int>[
    ...utf8.encode(_domainConfirmedEvent),
    ...bare.writeToBuffer(),
  ];
  final publicKey = SimplePublicKey(event.pubkey, type: KeyPairType.ed25519);
  final signature = Signature(event.signature, publicKey: publicKey);
  return _ed25519.verify(payload, signature: signature);
}
