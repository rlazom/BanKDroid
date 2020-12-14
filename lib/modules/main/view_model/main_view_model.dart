import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/common/notifiers/device_contact_list.dart';
import 'package:bankdroid/common/notifiers/loader_state.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:bankdroid/models/device_contact.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/modules/home/components/home/views/home_view.dart';
import 'package:bankdroid/modules/onboarding/on_boarding.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:bankdroid/service/sms_service/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';



class MainViewModel extends LoaderViewModel {
  final GlobalKey<ScaffoldState> mainScaffoldKey;
  SharedPreferencesService sharedPreferencesService;
  SmsService smsService = new SmsService();
  List<Operation> _listOperations;
  bool _isFirstTime;

  MainViewModel({@required this.mainScaffoldKey}) : this.sharedPreferencesService = new SharedPreferencesService();

  loadData(BuildContext context) async {
    print('MainViewModel - loadData() - BEGIN');
    await sharedPreferencesService.loadInstance();

    await _requestPermissions();
    await _loadContacts(context);
    await _loadOperations(context);

    _isFirstTime = sharedPreferencesService.isFirstTime();
    print('MainViewModel - loadData() - isFirstTime: $_isFirstTime');

    if(_isFirstTime) {
      print('MainViewModel - loadData() - isFirstTime');
      _navigateTo(context: context);
      return;
    }
    _navigateTo(context: context, routeTo: HomePage.route);
    print('MainViewModel - loadData() - END');
  }

  _requestPermissions() async {
    List permissions = [Permission.phone, Permission.sms, Permission.contacts,];
    for(Permission permission in permissions) {
      await permission.request();
    }
  }

  _loadContacts(BuildContext context) async {
    DeviceContactList deviceContactList = Provider.of<DeviceContactList>(context, listen: false);
    await deviceContactList.loadDeviceContactList();
  }

  _loadOperations(BuildContext context) async {
    print('HomeViewModel _reloadSMSOperations()');
//    BuildContext context = homeScaffoldKey.currentContext;

    if(await Permission.sms.request().isGranted && context != null) {
//      updateLoading();
      List<SmsMessage> messages = await smsService.readSms();

      OperationList operationListProvider = Provider.of<OperationList>(context, listen: false);

      _listOperations = await operationListProvider.reloadSMSOperations(messages);
      await _updateContactsOnTx(context);
      operationListProvider.addOperationList(_listOperations);

      print('HomeViewModel - _loadOperations() - Operations LOADED');
    }
  }

  _updateContactsOnTx(BuildContext context) async {
    DeviceContactList deviceContactList = Provider.of<DeviceContactList>(context, listen: false);

    for(Operation op in _listOperations) {
      if(op.tipoOperacion == TipoOperacion.TRANSFERENCIA) {
        var obsArr = op.observaciones.split(" ");
//        String obsTitle = obsArr.first;
        String obsContent = obsArr.last;

        DeviceContact contact = deviceContactList.getDeviceContactWithPhoneNumber(phoneNumber: obsContent);
        if(contact != null) {
          await contact.updateAvatar();
          op.contact = contact;
        }
      }
    }
  }

  _navigateTo({BuildContext context, String routeTo = OnBoarding.route}) {
    print('MainViewModel - _navigateTo(routeTo: $routeTo) - [context != null: ${context != null}]');

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (context != null) {
        Navigator.pushReplacementNamed(context, routeTo);
      }
    });
  }
}