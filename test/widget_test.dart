import 'package:earthnet_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds and shows the connect control', (tester) async {
    await tester.pumpWidget(const EarthNetApp());
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Esperando sismos…'), findsOneWidget);
  });
}
