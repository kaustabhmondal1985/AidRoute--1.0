class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });
}

class SupportedLanguages {
  static const List<SupportedLanguage> languages = [
    SupportedLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇬🇧',
    ),
    SupportedLanguage(
      code: 'es',
      name: 'Español',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    SupportedLanguage(
      code: 'fr',
      name: 'Français',
      nativeName: 'Français',
      flagEmoji: '🇫🇷',
    ),
    SupportedLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
    SupportedLanguage(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      flagEmoji: '🇮🇳',
    ),
    SupportedLanguage(
      code: 'mix',
      name: 'Easy Mix',
      nativeName: 'Easy Mix',
      flagEmoji: '🌐',
    ),
  ];

  static SupportedLanguage get defaultLanguage => languages.first;

  static SupportedLanguage getByCode(String code) {
    return languages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => defaultLanguage,
    );
  }
}
