import 'dart:convert';
import 'dart:io';

import 'package:earthnet_mobile/src/proto/earthnet.pb.dart';
import 'package:earthnet_mobile/src/verify.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _hex(String s) => [
  for (var i = 0; i < s.length; i += 2)
    int.parse(s.substring(i, i + 2), radix: 16),
];

String _toHex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  late Map<String, dynamic> vector;

  setUpAll(() {
    final data = jsonDecode(File('test/vectors/v0_1.json').readAsStringSync());
    vector = (data['vectors'] as List).cast<Map<String, dynamic>>().firstWhere(
      (v) => v['name'] == 'confirmed_event',
    );
  });

  test('Dart deterministic encoding matches Rust/prost (canonical bytes)', () {
    final event = ConfirmedEvent.fromBuffer(_hex(vector['wire_hex'] as String));
    final bare = event.deepCopy()..clearSignature();
    expect(_toHex(bare.writeToBuffer()), vector['proto_canonical_hex']);
  });

  test('a node-signed ConfirmedEvent verifies in Dart', () async {
    final event = ConfirmedEvent.fromBuffer(_hex(vector['wire_hex'] as String));
    expect(await verifyConfirmedEvent(event), isTrue);
  });

  test('a tampered ConfirmedEvent fails verification', () async {
    final event = ConfirmedEvent.fromBuffer(_hex(vector['wire_hex'] as String));
    event.magnitude = 9.9;
    expect(await verifyConfirmedEvent(event), isFalse);
  });
}
