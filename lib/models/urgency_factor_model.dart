class UrgencyFactorModel {
  final String id;
  final String userProvidedFact;
  final String urgencyFactor;
  final String impactExplanation;

  const UrgencyFactorModel({
    required this.id,
    required this.userProvidedFact,
    required this.urgencyFactor,
    required this.impactExplanation,
  });
}
