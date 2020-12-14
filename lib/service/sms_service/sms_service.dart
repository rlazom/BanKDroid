import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:sms_maintained/sms.dart';

import '../../models/resumen.dart';
import '../../models/operation.dart';
import '../../common/enums.dart';

class SmsService {

  Future<List<SmsMessage>> readSms() async {
    SmsQuery query = new SmsQuery();
    return await query.querySms(address: "PAGOxMOVIL");
  }

  bool isAlreadyConected(List<SmsMessage> smsCollection, SharedPreferences prefs) {
    if (smsCollection.any((sms) => sms.body.contains("autenticado"))) {
      smsCollection..sort((a, b) => b.dateSent.compareTo(a.dateSent));
      DateTime dateSent = smsCollection
          .firstWhere((sms) => sms.body.contains("autenticado"))
          .dateSent;

      int diff = DateTime.now().difference(dateSent).inMinutes;
      bool _sessionClosed = prefs.getBool('closed_session') ?? false;

      if(diff <= 60 && !_sessionClosed){
        return true;
      }
    }

    return false;
  }

  List<Object> getResumenOperaciones(List<Operation> operations) {
    List<ResumeMonth> list = new List<ResumeMonth>();

    int month = operations.first.fecha.month;
    int year = operations.first.fecha.year;
    List<Operation> listOperations = new List<Operation>();

    operations.forEach((Operation operation) {
      if (operation.fecha.year != year || operation.fecha.month != month) {
        ResumeMonth resumenDelMes =
            generateResumeOperationsXMonth(listOperations);
        list.add(resumenDelMes);

        listOperations.clear();
        month = operation.fecha.month;
        year = operation.fecha.year;
      }

      listOperations.add(operation);
    });

    ResumeMonth resumenDelMes = generateResumeOperationsXMonth(listOperations);
    list.add(resumenDelMes);

    return list;
  }

  static ResumeMonth generateResumeOperationsXMonth(List<Operation> listOperations) {
    Set<TipoOperacion> set = new Set<TipoOperacion>();
    listOperations.forEach((Operation operation) {
      set.add(operation.tipoOperacion);
    });

    List<TipoOperacion> typeOperationsNonDuplicated =
        new List<TipoOperacion>.from(set);
    List<TipoOperacion> typeOperationsSorted = typeOperationsNonDuplicated
      ..sort((a, b) => getOperationTitle(a).compareTo(getOperationTitle(b)));

    double resumenDb = 0.0;
    double resumenCr = 0.0;
    listOperations.forEach((Operation op) {
      op.naturaleza == NaturalezaOperacion.DEBITO
          ? resumenDb += op.importe
          : resumenCr += op.importe;
    });

    List<ResumeTypeOperation> listTypes = new List<ResumeTypeOperation>();
    typeOperationsSorted.forEach((TipoOperacion tipoOp) {
      double resumenTipOpDb = 0.0;
      double resumenTipOpCr = 0.0;

      listOperations.where((o) => o.tipoOperacion == tipoOp).forEach((f) {
        f.naturaleza == NaturalezaOperacion.DEBITO
            ? resumenTipOpDb += f.importe
            : resumenTipOpCr += f.importe;
      });
      var listOpsType = listOperations.where((o) => o.tipoOperacion == tipoOp).toList();

      ResumeTypeOperation typeOperation =
          new ResumeTypeOperation(tipoOp, resumenTipOpCr, resumenTipOpDb, listOpsType);
      listTypes.add(typeOperation);
    });

    ResumeMonth resumeMonth = new ResumeMonth(listOperations.first.fecha, resumenCr, resumenDb, listTypes);
    return resumeMonth;
  }
}