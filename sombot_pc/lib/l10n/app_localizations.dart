import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'hello': 'Hello',
      'welcome': 'Welcome',
    },
    'es': {
      'hello': 'Hola',
      'welcome': 'Bienvenido',
    },
    'km': {
      'hello': 'សួស្តី',
      'welcome': 'សូមស្វាគមន៍',
    },
    // Add more languages and keys here
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en', ''),
    Locale('es', ''),
    Locale('km', ''),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'km'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Usage in MaterialApp:
// localizationsDelegates: [
//   AppLocalizations.delegate,
//   GlobalMaterialLocalizations.delegate,
//   GlobalWidgetsLocalizations.delegate,
//   GlobalCupertinoLocalizations.delegate,
// ],
// supportedLocales: [
//   const Locale('en', ''),
//   const Locale('es', ''),
//   const Locale('km', ''),
// ],