import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The phone's anonymous Ed25519 identity (one pubkey = one vote in consensus).
/// The 32-byte seed is persisted so reputation accrues to a stable identity.
class Identity {
  Identity._(this._keyPair, this.publicKeyBytes);

  final SimpleKeyPair _keyPair;
  final List<int> publicKeyBytes;

  static final _ed = Ed25519();
  static const _seedKey = 'earthnet_identity_seed';

  static Future<Identity> loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    List<int> seed;
    final hex = prefs.getString(_seedKey);
    if (hex == null) {
      final fresh = await _ed.newKeyPair();
      seed = await fresh.extractPrivateKeyBytes();
      await prefs.setString(_seedKey, _toHex(seed));
    } else {
      seed = _fromHex(hex);
    }
    final kp = await _ed.newKeyPairFromSeed(seed);
    final pk = await kp.extractPublicKey();
    return Identity._(kp, pk.bytes);
  }

  /// Ed25519 signature over [message].
  Future<List<int>> sign(List<int> message) async {
    final sig = await _ed.sign(message, keyPair: _keyPair);
    return sig.bytes;
  }

  static String _toHex(List<int> b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  static List<int> _fromHex(String s) => [
    for (var i = 0; i < s.length; i += 2)
      int.parse(s.substring(i, i + 2), radix: 16),
  ];
}
