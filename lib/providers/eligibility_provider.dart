import 'package:flutter/material.dart';

import '../models/eligibility_model.dart';
import '../services/eligibility_service.dart';
import 'conversation_provider.dart';

class EligibilityProvider extends ChangeNotifier {
  final EligibilityService _service = EligibilityService();

  EligibilityModel? _eligibility;
  ProviderState _state = ProviderState.initial;
  String? _errorMessage;

  EligibilityModel? get eligibility => _eligibility;
  ProviderState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> evaluateEligibility({
    required double monthlyIncome,
    required int householdSize,
    required bool isResident,
  }) async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      _eligibility = await _service.checkEligibility(
        monthlyIncome: monthlyIncome,
        householdSize: householdSize,
        isResident: isResident,
      );
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Eligibility calculation failed.';
    } finally {
      notifyListeners();
    }
  }
}
