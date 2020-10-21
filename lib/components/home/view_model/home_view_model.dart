import 'dart:async';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class HomeViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> homeScaffoldKey;
  SharedPreferencesService sharedPreferencesService = new SharedPreferencesService();
  final loading = ValueNotifier<bool>(false);
  int currentIndex = 0;

  HomeViewModel({@required this.homeScaffoldKey}) {
    _loadData();
  }

  _loadData() async {
    print('_loadData()');
    await sharedPreferencesService.loadInstance();
  }


//  Future<bool> processLogin({@required BuildContext context}) async {
  Future<bool> processLogin() async {
    print('processLogin()');

    return true;
  }


  updateIndex({@required int newIndex}) {
    this.currentIndex = newIndex;
    notifyListeners();
  }

  updateLoading({@required bool newLoadingStatus}) {
    this.loading.value = newLoadingStatus;
  }
}