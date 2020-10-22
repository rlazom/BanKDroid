import 'dart:async';
import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/common/notifiers/loader_state.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/models/resumen.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:bankdroid/service/sms_service/sms_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';


class HomeViewModel extends LoaderViewModel {
  final GlobalKey<ScaffoldState> homeScaffoldKey;
  SharedPreferencesService sharedPreferencesService = new SharedPreferencesService();
  SmsService smsService = new SmsService();
//  final currentIndex = ValueNotifier<int>(0);
//  bool loading = true;
  int currentIndex = 0;

  HomeViewModel({@required this.homeScaffoldKey});

  loadData(BuildContext context) async {
    print('HomeViewModel _loadData()');
//    updateLoading();

    await sharedPreferencesService.loadInstance();

    await _requestPermissions();
    await reloadSMSOperations(context);

    this.markAsSuccess();
  }

  _requestPermissions() async {
    List permissions = [Permission.phone, Permission.sms, Permission.contacts,];
    for(Permission permission in permissions) {
      await permission.request();
    }
  }

  reloadSMSOperations(BuildContext context) async {
    print('HomeViewModel _reloadSMSOperations()');
//    BuildContext context = homeScaffoldKey.currentContext;

    if(await Permission.sms.request().isGranted && context != null) {
//      updateLoading();
      List<SmsMessage> messages = await smsService.readSms();
      List<Operation> listOperations = await smsService.reloadSMSOperations(messages);
      Provider.of<OperationList>(context, listen: false).addOperationList(listOperations);
      print('HomeViewModel _reloadSMSOperations() Operations LOADED');
//      updateLoading(loading: false);
    }
  }


//  Future<bool> processLogin({@required BuildContext context}) async {
  Future<bool> processLogin() async {
    print('processLogin()');

    return true;
  }


  updateIndex({@required int newIndex}) {
//    this.currentIndex.value = newIndex;
    this.currentIndex = newIndex;
    notifyListeners();
  }

//  updateLoading({bool loading = true}) {
////    if(this.loading.value != loading) {
////      this.loading.value = loading;
////      print('change loading: $loading');
////    }
//    if(this.loading != loading) {
//      this.loading = loading;
//      print('change loading: $loading');
//    }
//  }
}