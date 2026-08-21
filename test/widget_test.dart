import 'package:aidroute/main.dart';
import 'package:aidroute/screens/splash/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AidRouteApp builds splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AidRouteApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
