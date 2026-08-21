import 'package:flutter/material.dart';

import '../models/answer_model.dart';
import '../models/legal_category_model.dart';
import '../models/urgency_model.dart';
import '../services/triage_service.dart';
import 'conversation_provider.dart';

class TriageProvider extends ChangeNotifier {
  final TriageService _service = TriageService();

  LegalCategoryModel? _category;
  UrgencyModel? _urgency;
  ProviderState _state = ProviderState.initial;
  String? _errorMessage;
  String? _backendCategory;
  String? _caseSummary;

  LegalCategoryModel? get category => _category;
  UrgencyModel? get urgency => _urgency;
  ProviderState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get backendCategory => _backendCategory;
  String? get caseSummary => _caseSummary;

  Future<void> evaluateTriage(
    List<AnswerModel> answers,
    String category,
    String userMessage, {
    String? languageCode,
  }) async {
    _state = ProviderState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.evaluateTriage(
        answers: answers,
        category: category,
        userMessage: userMessage,
        languageCode: languageCode,
      );
      _category = res['category'] as LegalCategoryModel;
      _urgency = res['urgency'] as UrgencyModel;
      _backendCategory = res['backendCategory'] as String?;
      _caseSummary = res['caseSummary'] as String?;
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
      _errorMessage = 'Failed to evaluate intake triage. Tap retry.';
    } finally {
      notifyListeners();
    }
  }
}
