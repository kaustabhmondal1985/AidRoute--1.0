class AnswerModel {
  final String questionId;
  final String questionPrompt;
  final String responseText;
  final DateTime timestamp;

  const AnswerModel({
    required this.questionId,
    required this.questionPrompt,
    required this.responseText,
    required this.timestamp,
  });
}
