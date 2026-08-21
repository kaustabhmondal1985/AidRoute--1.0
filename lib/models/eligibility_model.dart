enum EligibilityResultStatus { eligible, conditionallyEligible, ineligible }

class EligibilityModel {
  final bool meetsIncomeCriteria;
  final bool isResident;
  final int householdSize;
  final double monthlyIncome;
  final EligibilityResultStatus status;
  final String statusExplanation;

  const EligibilityModel({
    required this.meetsIncomeCriteria,
    required this.isResident,
    required this.householdSize,
    required this.monthlyIncome,
    required this.status,
    required this.statusExplanation,
  });
}
