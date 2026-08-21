import 'package:aidroute/core/widgets/app_status_badge.dart';
import 'package:aidroute/models/answer_model.dart';
import 'package:aidroute/services/triage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TriageService Tests', () {
    final triageService = TriageService();

    test('Identifies urgent eviction notice as urgent triage', () async {
      final answers = [
        AnswerModel(
          questionId: 'q1',
          questionPrompt: 'What happened?',
          responseText:
              'I received an eviction notice with a court date in 3 days',
          timestamp: DateTime.now(),
        ),
      ];

      final res = await triageService.evaluateTriage(
        answers: answers,
        category: 'HOUSING_EVICTION',
        userMessage:
            'I received an eviction notice with a court date in 3 days',
      );
      final urgency = res['urgency'];

      expect(urgency.level, UrgencyLevel.urgent);
      expect(urgency.factors.isNotEmpty, isTrue);
      expect(urgency.factors.first.userProvidedFact, contains('court date'));
    });

    test('Identifies wage issue as moderate triage', () async {
      final answers = [
        AnswerModel(
          questionId: 'q1',
          questionPrompt: 'What happened?',
          responseText:
              'My employer did not pay my final wage paycheck last week',
          timestamp: DateTime.now(),
        ),
      ];

      final res = await triageService.evaluateTriage(
        answers: answers,
        category: 'EMPLOYMENT',
        userMessage: 'My employer did not pay my final wage paycheck last week',
      );
      final urgency = res['urgency'];

      expect(urgency.level, UrgencyLevel.moderate);
    });
  });
}
