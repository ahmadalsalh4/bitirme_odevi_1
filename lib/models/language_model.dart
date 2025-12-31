class LanguageModel {
  static const Map<String, String> languageNames = {
    'tr': 'TR',
    'en': 'EN',
    'ar': 'AR',
  };

  static List<String> get availableLanguages => languageNames.keys.toList();
}
