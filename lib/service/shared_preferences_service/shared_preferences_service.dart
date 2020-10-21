import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum SharePrefsAttribute{
  IS_DARK,
  IS_FIRST_TIME,
}

String getAttributeStr(SharePrefsAttribute attribute){
  return attribute.toString().split('.').last.toLowerCase();
}

class SharedPreferencesService {
  SharedPreferences prefs;

  Future loadInstance() async => prefs = await SharedPreferences.getInstance();

  bool isFirstTime() => prefs.getBool(getAttributeStr(SharePrefsAttribute.IS_FIRST_TIME)) ?? true;
  bool isDark() => prefs.getBool(getAttributeStr(SharePrefsAttribute.IS_DARK));
}