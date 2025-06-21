import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';

class AppLocaleNotifier extends ChangeNotifier {
  AppLocale _locale = AppLocale.es;

  String get locale => _locale.localeCode;
  
  Future <void> setLocale(AppLocale locale, {bool notify = true}) async{
    _locale = locale;
    if (notify) {
      notifyListeners();
    }
  }
}

enum AppLocale{
  es,
  en
}
extension AppLocaleExtension on AppLocale {
  String get localeCode {
    switch (this) {
      case AppLocale.en:
        return 'en';
      case AppLocale.es:
        return 'es';
    }
  }

  static List<AppLocale> locales() {
    return [
      AppLocale.en,
      AppLocale.es
    ];
  }

  static AppLocale appLocaleFromDBLanguageName(String language){
    AppLocale defaultAppLocale = AppLocale.es;
    Map<String, AppLocale> localeCodesByAppLocales = {
      "english": AppLocale.en,
      "spanish": AppLocale.es
    };
    AppLocale localeCode = localeCodesByAppLocales[language] ?? defaultAppLocale;
    return localeCode;
  }

  static bool localeLanguageValidator(String language){
    switch (language) {
      case "spanish":
        return true;
      case "english":
        return true;
      default:
        return false;
    }
  }

  static String localeCodeFromAppLocale(BuildContext context, AppLocale appLocale){
    String defaultLocaleCode = "es";
    Map<AppLocale, String> localeCodesByAppLocales = {
      AppLocale.en: "en",
      AppLocale.es: "es",
    };
    String localeCodeStr = localeCodesByAppLocales[appLocale] ?? defaultLocaleCode;
    return localeCodeStr;
  }

  static AppLocale appLocaleFromlocaleCode(String localeCodeStr){
    AppLocale defaultAppLocale = AppLocale.es;
    Map<String, AppLocale> localeCodesByAppLocales = {
      "en": AppLocale.en,
      "es": AppLocale.es
    };
    AppLocale localeCode = localeCodesByAppLocales[localeCodeStr] ?? defaultAppLocale;
    return localeCode;
  }
  
  String languageFromAppLocale(BuildContext context) {
    String defaultLanguage = AppLocalizations.of(context)!.languageSpanish;
    Map<AppLocale, String> languagesByAppLocales = {
      AppLocale.en: AppLocalizations.of(context)!.languageEnglish,
      AppLocale.es: AppLocalizations.of(context)!.languageSpanish
    };
    String currentLanguage = languagesByAppLocales[this] ?? defaultLanguage;
    return currentLanguage;
  }

  static String languageFromLocaleCodeStr(BuildContext context, String localeCodeStr) {
    String defaultLanguage = AppLocalizations.of(context)!.languageSpanish;
    Map<String, String> languagesByLocaleCodes = {
      "en": AppLocalizations.of(context)!.languageEnglish,
      "es": AppLocalizations.of(context)!.languageSpanish
    };
    String currentLanguage = languagesByLocaleCodes[localeCodeStr] ?? defaultLanguage;
    return currentLanguage;
  }

  String localeLocaleString(BuildContext context) {
    switch (this) {
      case AppLocale.en:
        return AppLocalizations.of(context)!.languageEnglish;
      case AppLocale.es:
        return AppLocalizations.of(context)!.languageSpanish;
    }
  }
  static String localeLocale(BuildContext context, String locale) {
    switch (locale) {
      case "en":
        return AppLocalizations.of(context)!.languageEnglish;
      case "es":
        return AppLocalizations.of(context)!.languageSpanish;
      default:
        return AppLocalizations.of(context)!.languageSpanish;
    }
  }
}