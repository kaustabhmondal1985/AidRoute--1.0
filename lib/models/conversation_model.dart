import 'answer_model.dart';
import 'message_model.dart';

class ConversationModel {
  final String id;
  final String languageCode;
  final List<MessageModel> messages;
  final List<AnswerModel> answers;
  final bool isCompleted;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.languageCode,
    required this.messages,
    required this.answers,
    required this.isCompleted,
    required this.createdAt,
  });
}
