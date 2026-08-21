import 'package:aidroute/models/message_model.dart';
import 'package:aidroute/services/conversation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationService Tests', () {
    final service = ConversationService();

    test('Initial greeting contains options in English', () async {
      final msg = await service.getInitialAiMessage('en');
      expect(msg.sender, MessageSender.ai);
      expect(msg.options, isNotNull);
      expect(msg.options!.isNotEmpty, isTrue);
    });

    test('Adapts follow-up question when user mentions eviction', () async {
      final msg = await service.processUserResponse(
        userText: 'I received an eviction notice from landlord',
        history: [],
        languageCode: 'en',
        category: 'HOUSING_EVICTION',
      );

      expect(msg.sender, MessageSender.ai);
      expect(msg.text.toLowerCase(), contains('notice'));
    });
  });
}
