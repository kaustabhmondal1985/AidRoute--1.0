enum QuestionType { text, singleChoice, multiChoice, date }

class QuestionModel {
  final String id;
  final String prompt;
  final QuestionType type;
  final List<String>? options;
  final String? categoryHint;

  const QuestionModel({
    required this.id,
    required this.prompt,
    required this.type,
    this.options,
    this.categoryHint,
  });
}
