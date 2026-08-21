import 'package:flutter/material.dart';

import '../models/case_summary_model.dart';
import '../services/submission_service.dart';
import 'conversation_provider.dart';

class SubmissionProvider extends ChangeNotifier {
  final SubmissionService _service = SubmissionService();

  SubmissionResultModel? _result;
  ProviderState _state = ProviderState.initial;
  String? _errorMessage;

  SubmissionResultModel? get result => _result;
  ProviderState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> submitCase(CaseSummaryModel summary) async {
    _state = ProviderState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _service.submitCase(summary);
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Case submission failed. Please tap retry.';
    } finally {
      notifyListeners();
    }
  }
}
