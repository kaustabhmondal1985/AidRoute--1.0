import 'package:flutter/material.dart';

import '../core/localization/supported_languages.dart';

class LanguageProvider extends ChangeNotifier {
  SupportedLanguage _currentLanguage = SupportedLanguages.defaultLanguage;

  SupportedLanguage get currentLanguage => _currentLanguage;
  String get currentLanguageCode => _currentLanguage.code;
  String get currentLanguageName => _currentLanguage.name;

  void selectLanguage(SupportedLanguage language) {
    if (_currentLanguage.code != language.code) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void setLanguage(String code) {
    selectLanguage(SupportedLanguages.getByCode(code));
  }
}

