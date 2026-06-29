import 'package:earthnet_mobile/main.dart';
import 'package:earthnet_mobile/src/pulse_indicator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app builds: live indicator + connect control', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const EarthNetApp());
    expect(find.byType(PulseIndicator), findsOneWidget);
    expect(find.text('Conectar'), findsOneWidget);
  });
}
