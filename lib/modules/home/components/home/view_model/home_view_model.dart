import 'package:bankdroid/common/notifiers/loader_state.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:bankdroid/service/sms_service/sms_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class HomeViewModel extends LoaderViewModel {
  final GlobalKey<ScaffoldState> homeScaffoldKey;
  SharedPreferencesService sharedPreferencesService = new SharedPreferencesService();
  SmsService smsService = new SmsService();
  int currentIndex = 0;

  HomeViewModel({@required this.homeScaffoldKey});

  loadData(BuildContext context) async {
    print('HomeViewModel _loadData()');
    await sharedPreferencesService.loadInstance();
    this.markAsSuccess();
  }


  updateIndex({@required int newIndex}) {
    this.currentIndex = newIndex;
    notifyListeners();
  }
}