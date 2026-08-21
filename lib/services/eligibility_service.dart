import '../models/eligibility_model.dart';

class EligibilityService {
  Future<EligibilityModel> checkEligibility({
    required double monthlyIncome,
    required int householdSize,
    required bool isResident,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Threshold baseline: $2,500 + $600 per household member
    final maxIncomeThreshold = 2500.0 + (householdSize * 600.0);

    final meetsIncome = monthlyIncome <= maxIncomeThreshold;
    final isEligible = meetsIncome && isResident;

    return EligibilityModel(
      meetsIncomeCriteria: meetsIncome,
      isResident: isResident,
      householdSize: householdSize,
      monthlyIncome: monthlyIncome,
      status: isEligible
          ? EligibilityResultStatus.eligible
          : EligibilityResultStatus.conditionallyEligible,
      statusExplanation: isEligible
          ? 'Based on the information provided, this intake meets the preliminary eligibility criteria for legal-aid review.'
          : 'Based on the reported income, this intake requires secondary financial verification by clinic intake staff.',
    );
  }
}
