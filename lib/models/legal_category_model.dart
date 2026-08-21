class LegalCategoryModel {
  final String id;
  final String title;
  final String description;
  final double confidenceScore;
  final List<String> commonKeywords;

  const LegalCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.confidenceScore,
    required this.commonKeywords,
  });
}
