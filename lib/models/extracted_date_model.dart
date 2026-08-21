class ExtractedDateModel {
  final String id;
  final DateTime date;
  final String label;
  final String sourceDocumentName;
  final String? contextSnippet;

  const ExtractedDateModel({
    required this.id,
    required this.date,
    required this.label,
    required this.sourceDocumentName,
    this.contextSnippet,
  });
}
