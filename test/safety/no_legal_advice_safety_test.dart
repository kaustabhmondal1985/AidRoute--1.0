import 'package:aidroute/core/constants/app_constants.dart';
import 'package:aidroute/core/widgets/disclaimer_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('No-Legal-Advice Safety Tests', () {
    test('App disclaimer explicitly states no legal advice boundary', () {
      expect(AppConstants.disclaimerText, contains('NEVER provides legal advice'));
      expect(AppConstants.disclaimerText, contains('intake and triage routing companion'));
    });

    testWidgets('DisclaimerBanner renders warning text in UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DisclaimerBanner(),
          ),
        ),
      );

      expect(find.byType(DisclaimerBanner), findsOneWidget);
      expect(find.textContaining('NEVER provides legal advice'), findsOneWidget);
    });

    test('Prohibited legal advice phrases are not used in app constants', () {
      final text = AppConstants.disclaimerText.toLowerCase();
      expect(text.contains('you should sue'), isFalse);
      expect(text.contains('you will win'), isFalse);
      expect(text.contains('you definitely have a case'), isFalse);
    });
  });
}
