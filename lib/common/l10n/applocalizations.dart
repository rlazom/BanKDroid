import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'localization_strings.dart';

class Localization {
  final Locale locale;

  Localization(this.locale);

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'es': es,
    'en': en
  };

  _getValue(String key) => _localizedValues[locale.languageCode][key];
  getValueOfKey(String key) => _localizedValues[locale.languageCode][key];

  String get appTitleText => _getValue(AppTitleText);

  String get toText => _getValue(ToText);
  String get theText => _getValue(TheText);

  String get usernameText => _getValue(UsernameText);
  String get passwordText => _getValue(PasswordText);
  String get loadingText => _getValue(LoadingText);
  String get expireInText => _getValue(ExpireInText);
  String get availableText => _getValue(AvailableText);

  String get collectionDataText => _getValue(CollectionDataText);

  String get phoneNumberHint => _getValue(PhoneNumberHint);
  String get passwordHint => _getValue(PasswordHint);

  String get patternFieldErrorMessage => _getValue(PatternFieldErrorMessage);
  String get requiredFieldErrorMessage => _getValue(RequiredFieldErrorMessage);
  String get socketExceptionErrorMessage => _getValue(SocketExceptionErrorMessage);
  String get pushToCEErrorMessage => _getValue(PushToCEErrorMessage);
  String get getDataFromCEErrorMessage => _getValue(GetDataFromCEErrorMessage);
}

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) {
    return SynchronousFuture<Localization>(Localization(locale));
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
