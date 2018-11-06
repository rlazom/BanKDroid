import 'package:shared_preferences/shared_preferences.dart';

import 'resumen.dart';
import 'operation.dart';

import 'dart:async';
import 'package:sms/sms.dart';

class OperationListProvider {
  double saldoCUP;
  double saldoCUC;

  Future<List<SmsMessage>> ReadSms() async {
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

  Future<List<Operation>> reloadSMSOperations(List<SmsMessage> smsCollection) async {
    List<Operation> operations = new List<Operation>();

    int idOperationSaldo = 0;
    smsCollection.forEach((SmsMessage sms) {
      if (esConsultaDeSaldo(sms)) {
        idOperationSaldo++;
      }
      List<Operation> operationsSMS = smsToOperations(sms, idOperationSaldo);
      operations..addAll(operationsSMS);
    });

    List<Operation> operationsRecargaUltOps = operations.where((o) => o.tipoOperacion == TipoOperacion.RECARGA_MOVIL && o.tipoSms == TipoSms.ULTIMAS_OPERACIONES).toList();
    operations.where((o) => o.tipoOperacion == TipoOperacion.RECARGA_MOVIL && o.tipoSms != TipoSms.ULTIMAS_OPERACIONES).toList().forEach((op) {
      if (operationsRecargaUltOps.any((p) => p.idOperacion == op.idOperacion)) {
        op.moneda = operationsRecargaUltOps.firstWhere((p) => p.idOperacion == op.idOperacion).moneda;
        op.importe = op.moneda == MONEDA.CUC ? op.importe : op.importe * 25.0;
      }
    });

    // Arreglando los mensajes de transferencia recivida en cuenta CUC con importe en CUP
    operations.where((op) => op.observaciones != "")
        .where((op) => op.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO && (op.observaciones.split(" ")[1].substring(0,4) == '9202' || op.observaciones.split(" ")[1].substring(0,4) == '9200') && op.fullText.indexOf('CUC') < 0)
        .forEach((op) {
          print(op.fecha.toString() + ' ' + op.idOperacion + ' ' + op.tipoSms.toString() + ' ' + op.observaciones + ' ' + op.moneda.toString() + ' ' + op.importe.toString());
          if(operations.any((o) => o.idOperacion == op.idOperacion && o.moneda == op.moneda && o.importe != op.importe)){
            op.importe = operations.firstWhere((o) => o.idOperacion == op.idOperacion && o.moneda == op.moneda && o.importe != op.importe).importe;
          }
          else{
            op.importe = op.importe / 25.0;
          }

    });

    // Remove duplicate List elements
    Set<Operation> set = new Set<Operation>();
    set.addAll(operations.where((o) => o.isSaldoReal)); // Agregar 1ro las operaciones con saldo real y fecha-hora
    set.addAll(operations
        .where((o) => !o.isSaldoReal)
        .toList()
        .reversed); // Agregar el resto sin sobreescribir las que ya estaban en la lista

    List<Operation> operationsNonDuplicated = new List<Operation>.from(set);

    // Order List elements
    List<Operation> operationsSorted = operationsNonDuplicated
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    // Agregar los saldos restantes a las operaciones
    List<Operation> operationsWithSaldo = addSaldoToOperationsXMon(operationsSorted, MONEDA.CUP);
    operationsWithSaldo = addSaldoToOperationsXMon(operationsWithSaldo, MONEDA.CUC);

    if (operationsWithSaldo.any((p) => p.moneda == MONEDA.CUP)) {
      this.saldoCUP =
          operationsWithSaldo.firstWhere((o) => o.moneda == MONEDA.CUP).saldo;
    }
    if (operationsWithSaldo.any((p) => p.moneda == MONEDA.CUC)) {
      this.saldoCUC =
          operationsWithSaldo.firstWhere((o) => o.moneda == MONEDA.CUC).saldo;
    }

    // Eliminar las operaciones de Consulta de Saldo
    operationsWithSaldo
        .removeWhere((op) => op.tipoOperacion == TipoOperacion.SALDO);

    return operationsWithSaldo;
  }

  static bool esConsultaDeSaldo(SmsMessage message) {
    return getTipoSms(message) == TipoSms.CONSULTAR_SALDO;
  }

  static List<Operation> smsToOperations(SmsMessage message, int idOperationSaldo) {
    TipoSms tipoSms = getTipoSms(message);
    List<Operation> list = new List<Operation>();

    var lines = message.body.split("\n");
    DateTime smsDate = message.date;

    if (tipoSms == TipoSms.ULTIMAS_OPERACIONES) {
      for (int i = 2; i < lines.length - 1; i++) {
        if (lines[i].contains("INFO:")) continue;

        Operation operation = new Operation();
        operation.tipoSms = TipoSms.ULTIMAS_OPERACIONES;

        if(lines[i].trim()=="")
          continue;

        var items = lines[i].split(";");
        String dateStr = items[0].trim();

        var parts = dateStr.split('/');

        DateTime date = new DateTime(int.parse(parts.elementAt(2)),
            int.parse(parts.elementAt(1)), int.parse(parts.elementAt(0)));

        if (date.isAfter(smsDate)) {
          date = smsDate;
        }

        operation.idOperacion = (items[5].trim()).split(" ")[0].trim();
        operation.fecha = date;
        operation.importe = double.parse(items[3].trim());
        operation.tipoOperacion = getTipoOperacion(items[1].trim() + ' ' + items[5].trim().split(" ")[0].trim(), operation.importe);
        operation.naturaleza = getNaturalezaOperacion(items[2].trim());
        operation.moneda = getMoneda(items[4].trim());

        list.add(operation);
      }
    } else if (tipoSms == TipoSms.CONSULTAR_SALDO) {
      Operation operation = new Operation();
      operation.idOperacion = idOperationSaldo.toString();
      operation.tipoOperacion = TipoOperacion.SALDO;
      operation.tipoSms = TipoSms.CONSULTAR_SALDO;
      operation.fecha = message.date;
      operation.moneda = getMoneda(lines[2].trim().split(" ")[4].trim());
      operation.saldo = double.parse(lines[1].trim().split(" ")[3].trim());
      operation.isSaldoReal = true;
      operation.fullText = message.body.trim();
      list.add(operation);
    } else if (tipoSms == TipoSms.RECARGA_MOVIL) {
      Operation operation = new Operation();
      operation.idOperacion = lines[0].split(". ")[4].split(": ")[1].toString();
      operation.tipoOperacion = TipoOperacion.RECARGA_MOVIL;
      operation.tipoSms = TipoSms.RECARGA_MOVIL;
      operation.fecha = message.date;
      operation.moneda = null;
      operation.importe = double.parse(lines[0].split(". ")[2].split(": ")[1].split(" ")[0].trim()).abs();
      operation.saldo = double.parse(lines[0].split(". ")[5].split(": ")[1].trim()).abs();
      operation.isSaldoReal = true;
      var phoneTemp = lines[0].split(". ")[3].split(": ")[1].trim();
      if(phoneTemp.length == 8){
        phoneTemp = '+53' + phoneTemp;
      }
      operation.observaciones = "Movil: " + phoneTemp;
      operation.fullText = message.body.trim();
      list.add(operation);
    } else if (tipoSms == TipoSms.FACTURA_PAGADA ||
        tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {

      Operation operation = new Operation();
      operation.fecha = message.date;
      operation.fullText = message.body.trim();

      if (tipoSms == TipoSms.FACTURA_PAGADA) {
        operation.idOperacion = lines[3].trim().split(" ")[2].trim();
        var factura = lines[1].trim().split(": ")[1].trim();
        operation.observaciones = "Factura: " + factura;
        operation.importe = double.parse(lines[2].trim().split(" ")[2].trim());
        operation.tipoOperacion = getTipoOperacion(lines[0], operation.importe);
        operation.tipoSms = TipoSms.FACTURA_PAGADA;
        operation.naturaleza = NaturalezaOperacion.DEBITO;
        operation.moneda = getMoneda(lines[2].trim().split(" ")[3].trim());
        operation.saldo = double.parse(lines[4].trim().split(" ")[3].trim());
        operation.isSaldoReal = true;
      } else if (tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO) {
        operation.idOperacion = lines[0].trim().split(" ")[14].trim();
        var cuenta = lines[0].trim().split("cuenta")[1].trim().split(" ")[0].trim();
        operation.observaciones = "Cuenta: " + cuenta;
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
        operation.tipoSms = TipoSms.TRANSFERENCIA_RX_SALDO;
        operation.naturaleza = NaturalezaOperacion.CREDITO;
        if(cuenta.substring(0,4) == '9202' || cuenta.substring(0,4) == '9200'){
          operation.moneda = MONEDA.CUC;
        }
        else{
          operation.moneda = getMoneda(lines[0].trim().split(" ")[11].trim());
        }
        operation.importe = double.parse(lines[0].trim().split(" ")[10].trim());
      } else if (tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
        operation.idOperacion = lines[5].trim().split(" ")[2].trim();
        var cuenta = lines[1].trim().split(" ")[1].trim();
        operation.observaciones = "Beneficiario: " + cuenta;
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
        operation.tipoSms = TipoSms.TRANSFERENCIA_TX_SALDO;
        operation.naturaleza = NaturalezaOperacion.DEBITO;
        operation.moneda = getMoneda(lines[3].trim().split(" ")[2].trim());
        operation.importe = double.parse(lines[3].trim().split(" ")[1].trim());
        operation.saldo = double.parse(lines[4].trim().split(" ")[3].trim());
        operation.isSaldoReal = true;
      }
      list.add(operation);
    }
    return list;
  }

  static List<Operation> addSaldoToOperationsXMon(List<Operation> operationsSorted, MONEDA moneda) {
    double firstSaldo = 0.0;
    for (final f in operationsSorted.where((o) => o.moneda == moneda)) {
      if (f.isSaldoReal) {
        firstSaldo += f.saldo;
        break;
      }
      f.naturaleza == NaturalezaOperacion.CREDITO
          ? firstSaldo += f.importe
          : firstSaldo -= f.importe;
    }
    double previousSaldo = 0.0;
    NaturalezaOperacion previousNatOper = NaturalezaOperacion.DEBITO;
    if (operationsSorted.length > 0 && operationsSorted.any((p) => p.moneda == moneda)) {
      operationsSorted.where((o) => o.moneda == moneda).first.saldo = firstSaldo;
      previousSaldo = firstSaldo;
      previousNatOper = operationsSorted.where((o) => o.moneda == moneda).first.naturaleza;
    }
    double previousImporte = 0.0;
    operationsSorted.where((o) => o.moneda == moneda).forEach((f) {
      if (!f.isSaldoReal) {
        previousNatOper == NaturalezaOperacion.CREDITO
            ? f.saldo = previousSaldo - previousImporte
            : f.saldo = previousSaldo + previousImporte;
      }
      previousImporte = f.importe;
      previousSaldo = f.saldo;
      previousNatOper = f.naturaleza;
    });

    // TODO: Arreglar funcion de agregar operaciones de ajuste
    // BEGIN - Agregando operaciones de ajuste - CON ERROR
    /*
    var first = true;
    Operation previousOperation = new Operation();
    List<Operation> operationsFinal = new List<Operation>();
    int idFix = 1;
    for(Operation f in operationsSorted.where((o) => o.moneda == moneda)){
      if(first) {
        previousOperation = f;
        first = false;
        operationsFinal.add(f);
        continue;
      }
      var negativo = f.naturaleza == NaturalezaOperacion.CREDITO;
      if(double.parse((previousOperation.saldo + (negativo ? -previousOperation.importe : previousOperation.importe)).toStringAsFixed(2)) == f.saldo){
        operationsFinal.add(f);
      }
      else{
        // Agregar operacion de ajuste
        var fixOperation = new Operation();
        fixOperation.saldo = previousOperation.saldo - (negativo ? previousOperation.importe : -previousOperation.importe);
        fixOperation.importe = previousOperation.saldo - (negativo ? -f.saldo : f.saldo);
        fixOperation.naturaleza = (negativo ? NaturalezaOperacion.DEBITO : NaturalezaOperacion.CREDITO);
        fixOperation.tipoOperacion = TipoOperacion.MISSING;
        fixOperation.moneda = moneda;
        fixOperation.isSaldoReal = false;
        fixOperation.fecha = previousOperation.fecha;
        fixOperation.idOperacion = "FIX" + (idFix++).toString();
        operationsFinal.add(fixOperation);
        operationsFinal.add(f);
      }
      previousOperation = f;
    }
    */
    // END - Agregando operaciones de ajuste - CON ERROR

//    return operationsFinal;
    return operationsSorted;
  }

  static TipoSms getTipoSms(SmsMessage message) {
    if (message.body.contains("La consulta de saldo") && message.body.contains("Saldo Contable"))
      return TipoSms.CONSULTAR_SALDO;
    else if (message.body.contains("Fallo la consulta de saldo"))
      return TipoSms.CONSULTAR_SALDO_ERROR;
    else if (message.body.contains("La Transferencia"))
      return TipoSms.TRANSFERENCIA_TX_SALDO;
    else if (message.body.contains("Se ha realizado una transferencia"))
      return TipoSms.TRANSFERENCIA_RX_SALDO;
    else if (message.body.contains("Fallo la transferencia"))
      return TipoSms.TRANSFERENCIA_FALLIDA;
    else if (message.body.contains("Consulta de Servicio Error"))
      return TipoSms.ERROR_FACTURA;
    else if (message.body.contains("  Factura: "))
      return TipoSms.FACTURA;
    else if (message.body.contains("El pago de la factura"))
      return TipoSms.FACTURA_PAGADA;
    else if (message.body.contains("Usted se ha autenticado en la plataforma"))
      return TipoSms.AUTENTICAR;
    else if (message.body.contains("El código de activación"))
      return TipoSms.INFO_CODIGO_ACTIVACION;
    else if (message.body.contains("Para obtener el codigo de activacion"))
      return TipoSms.ERROR_CODIGO_ACTIVACION;
    else if (message.body.contains("La operacion de registro fue completada"))
      return TipoSms.REGISTRAR_SUCESS;
    else if (message.body.contains("Error de autenticacion,"))
      return TipoSms.ERROR_AUTENTICACION;
    else if (message.body.contains("Error "))
      return TipoSms.ERROR;
    else if (message.body.contains("Fallo la consulta de servicio. Para realizar esta operacion"))
      return TipoSms.ERROR_SERVICIO_SIN_AUTENTICACION;
    else if (message.body.contains("Fallo la consulta de las ultimas operaciones"))
      return TipoSms.ERROR_ULTIMAS_OPERACIONES;
    else if (message.body.contains("Banco Metropolitano Ultimas operaciones"))
      return TipoSms.ULTIMAS_OPERACIONES;
    else if (message.body.contains("La consulta de saldo") && message.body.contains("Nombre Cuenta"))
      return TipoSms.CONSULTAR_ALL_ACCOUNTS;
    else if (message.body.contains("La recarga se realizo con exito"))
      return TipoSms.RECARGA_MOVIL;
    else
      return TipoSms.DEFAULT;
  }

  TipoSms publicGetTipoSms(SmsMessage message) {
    return getTipoSms(message);
  }

  bool isOperationsReload(SmsMessage message){
    TipoSms tipoSms = getTipoSms(message);

    return (tipoSms == TipoSms.CONSULTAR_SALDO
        || tipoSms == TipoSms.ULTIMAS_OPERACIONES
        || tipoSms == TipoSms.FACTURA_PAGADA
        || tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO
        || tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO);
  }

  static TipoOperacion getTipoOperacion(String cadena, double importe) {
    String idOperacion = cadena.split(" ")[0];
    String idTransaccion = cadena.split(" ")[1].substring(0,2);
    
    TipoOperacion tipoServicio = TipoOperacion.DEFAULT;
    if (cadena != null) {
      if (idOperacion == "AY")
        tipoServicio = TipoOperacion.ATM;
      else if (idOperacion == "TELF" || cadena.contains("telef"))
        tipoServicio = TipoOperacion.TELEFONO;
      else if (idOperacion == "ELECT" || cadena.contains("electricidad"))
        tipoServicio = TipoOperacion.ELECTRICIDAD;
      else if (idOperacion == "RECA" || cadena.contains("recarga"))
        tipoServicio = TipoOperacion.RECARGA_MOVIL;
      else if (idOperacion == "UU")
        tipoServicio = TipoOperacion.AJUSTE;
      else if (idOperacion == "YY" && idTransaccion == "YY")    // TRANSFERENCIA ATM
        tipoServicio = TipoOperacion.TRANSFERENCIA;
      else if (idOperacion == "TRAN" && idTransaccion == "MM")  // TRANSFERENCIA MOVIL
        tipoServicio = TipoOperacion.TRANSFERENCIA;
      else if (idOperacion == "MULT" && idTransaccion == "YY")
        tipoServicio = TipoOperacion.MULTA;
      else if (idOperacion == "EV" && importe >= 0.00)
        tipoServicio = TipoOperacion.SALARIO;
      else if (idOperacion == "EV" && importe < 0.00)
        tipoServicio = TipoOperacion.DESCUENTO_NOMINA;
      else if (idOperacion == "TL")
        tipoServicio = TipoOperacion.OP_VENTANILLA;
      else if (idOperacion == "EB")
        tipoServicio = TipoOperacion.JUBILACION;
      else if (idOperacion == "IO")
        tipoServicio = TipoOperacion.INTERES;
      else if (idOperacion == "AP")
        tipoServicio = TipoOperacion.POS;
    }
    return tipoServicio;
  }

  static NaturalezaOperacion getNaturalezaOperacion(String cadena) {
    NaturalezaOperacion naturalezaOperacion = NaturalezaOperacion.DEBITO;
    if (cadena != null) {
      if (cadena.contains("CR"))
        naturalezaOperacion = NaturalezaOperacion.CREDITO;
    }
    return naturalezaOperacion;
  }

  static MONEDA getMoneda(String cadena) {
    MONEDA moneda = MONEDA.CUP;
    if (cadena != null) {
      if (cadena.contains("CUC"))
        moneda = MONEDA.CUC;
    }
    return moneda;
  }

  static double castMoney(double imp) {
    return (imp * 100).floor().roundToDouble() / 100;
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