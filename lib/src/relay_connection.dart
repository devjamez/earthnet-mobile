import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'proto/earthnet.pb.dart';

/// A live relay subscription: connect, then receive decoded ConfirmedEvents.
///
/// On Android this is held open by a foreground service so alerts arrive with
/// the screen off. Callers should still [verifyConfirmedEvent] before trusting.
class RelaySubscription {
  RelaySubscription._(this._channel);

  final WebSocketChannel _channel;

  /// Connects to a relay `/subscribe` WebSocket, e.g.
  /// `ws://10.0.2.2:8090/subscribe` (Android emulator → host).
  factory RelaySubscription.connect(Uri relayWsUri) =>
      RelaySubscription._(WebSocketChannel.connect(relayWsUri));

  /// Completes when the socket is connected; throws on connection failure.
  Future<void> get ready => _channel.ready;

  /// Stream of decoded ConfirmedEvents (binary frames only).
  Stream<ConfirmedEvent> get events => _channel.stream
      .where((m) => m is List<int>)
      .map((m) => ConfirmedEvent.fromBuffer(Uint8List.fromList(m as List<int>)));

  Future<void> close() => _channel.sink.close();
}
