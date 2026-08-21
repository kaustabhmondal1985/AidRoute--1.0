import 'package:flutter/material.dart';

import '../models/lawyer_match_model.dart';
import '../services/matching_service.dart';
import 'conversation_provider.dart';

class MatchingProvider extends ChangeNotifier {
  final MatchingService _service = MatchingService();

  List<LawyerMatchModel> _matches = [];
  LawyerMatchModel? _selectedMatch;
  ProviderState _state = ProviderState.initial;

  List<LawyerMatchModel> get matches => _matches;
  LawyerMatchModel? get selectedMatch => _selectedMatch;
  ProviderState get state => _state;

  Future<void> fetchMatches(String categoryId, String languageCode) async {
    _state = ProviderState.loading;
    notifyListeners();

    try {
      // The service will handle category conversion
      _matches = await _service.findMatches(
        categoryId: categoryId,
        languageCode: languageCode,
      );
      if (_matches.isNotEmpty) {
        _selectedMatch = _matches.first;
      }
      _state = ProviderState.success;
    } catch (e) {
      _state = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void selectMatch(LawyerMatchModel match) {
    _selectedMatch = match;
    notifyListeners();
  }
}
