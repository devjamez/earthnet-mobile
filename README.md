> 🌎 Part of **[EarthNet](https://github.com/devjamez/earthnet)** — open-source, decentralized earthquake early warning for Latin America.

# earthnet-mobile

Android-first Flutter client for [EarthNet](https://github.com/devjamez/earthnet-protocol).
Holds a relay WebSocket open, verifies each `ConfirmedEvent`'s Ed25519 signature,
and computes the **S-wave countdown locally** from the epicenter + origin time and
the device's own location (the client never sends its location upstream).

## What works (v0.1)

- `src/relay_connection.dart` â€” subscribe to a relay `/subscribe` WebSocket.
- `src/verify.dart` â€” Ed25519 verification matching the protocol scheme;
  cross-checked byte-for-byte against the Rust/prost conformance vector.
- `src/countdown.dart` â€” seconds of warning before S-wave arrival (geohash +
  haversine + wave velocities).
- Minimal UI listing incoming alerts with verification + countdown.

> Android-first by design (iOS can't hold background sockets â€” DESIGN Â§6).
> NOT yet: foreground service for screen-off delivery, device GPS, alert
> sound/vibration, on-device detection (v1.1 via the Rust core).

## Develop

```sh
flutter pub get
flutter test            # conformance (cross-lang) + countdown + widget
flutter run             # against a relay; emulator â†’ host is ws://10.0.2.2:8090/subscribe
```

Generated Dart protobuf lives in `lib/src/proto/` (regenerate with
`protoc -Iproto --dart_out=lib/src/proto proto/earthnet.proto`).

## License

GPL-3.0-or-later.
