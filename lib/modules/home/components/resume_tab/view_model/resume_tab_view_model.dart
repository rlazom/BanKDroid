import 'package:bankdroid/common/notifiers/loader_state.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/models/resumen.dart';
import 'package:bankdroid/service/shared_preferences_service/shared_preferences_service.dart';
import 'package:bankdroid/service/sms_service/sms_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ResumeTabViewModel extends LoaderViewModel {
  final GlobalKey<ScaffoldState> resumeTabScaffoldKey;
  SharedPreferencesService sharedPreferencesService = new SharedPreferencesService();
  SmsService smsService = new SmsService();
//  final loading = ValueNotifier<bool>(true);

  bool isCurrencyCUP = true;
  List<ResumeMonth> resumeOperationsCUP = new List<ResumeMonth>();
  List<ResumeMonth> resumeOperationsCUC = new List<ResumeMonth>();
  Operation lastOperationCUP;
  Operation lastOperationCUC;
  double balanceCUP;
  double balanceCUC;

  ResumeTabViewModel({@required this.resumeTabScaffoldKey});

  loadData(BuildContext context) async {
    print('ResumeTabViewModel _loadData()');
//    updateLoading();
//    BuildContext context = resumeTabScaffoldKey.currentContext;
    await sharedPreferencesService.loadInstance();
    var operationListProvider = Provider.of<OperationList>(context, listen: false);

    if(operationListProvider.listCup.isNotEmpty) {
      List<ResumeMonth> resume = smsService.getResumenOperaciones(operationListProvider.listCup);
      resumeOperationsCUP.addAll(resume);
      lastOperationCUP = operationListProvider.listCup.first;
      balanceCUP = lastOperationCUP.saldo;
    }
    if(operationListProvider.listCuc.isNotEmpty) {
      List<ResumeMonth> resume = smsService.getResumenOperaciones(operationListProvider.listCuc);
      resumeOperationsCUC.addAll(resume);
      lastOperationCUC = operationListProvider.listCuc.first;
      balanceCUC = lastOperationCUC.saldo;
    }

    this.markAsSuccess();
    print('ResumeTabViewModel _loadData() LOADED');
  }

  toggleCurrency() {
    if((isCurrencyCUP && balanceCUC != null) || (!isCurrencyCUP && balanceCUP != null))
    isCurrencyCUP = !isCurrencyCUP;
    notifyListeners();
  }
}