import 'resumen.dart';
import 'operation.dart';

import 'dart:async';
import 'package:sms/sms.dart';

class OperationListProvider {
  Future<List<SmsMessage>> readSms() async {
    SmsQuery query = new SmsQuery();
    return await query.querySms(address: "PAGOxMOVIL");
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

    // Remove duplicate List elements
    Set<Operation> set = new Set<Operation>();
    set.addAll(operations.where((o) => o.isSaldoReal));   // Agregar 1ro las operaciones con saldo real y fecha-hora
    set.addAll(operations.where((o) => !o.isSaldoReal));  // Agregar el resto sin sobreescribir las que ya estaban en la lista
    List<Operation> operationsNonDuplicated = new List<Operation>.from(set);

    // Order List elements
    List<Operation> operationsSorted = operationsNonDuplicated..sort((a, b) => b.fecha.compareTo(a.fecha));

    // Agregar los saldos restantes a las operaciones
    List<Operation> operationsWithSaldo = addSaldoToOperationsXMon(operationsSorted, MONEDA.CUP);
    operationsWithSaldo = addSaldoToOperationsXMon(operationsWithSaldo, MONEDA.CUC);

    // Eliminar las operaciones de Consulta de Saldo
    operationsWithSaldo.removeWhere((op) =>
    op.tipoOperacion == TipoOperacion.DEFAULT);

//    return operationsSorted;
    return operationsWithSaldo;
  }

  Future<List<Operation>> getOperationsXMoneda(List<Operation> allOperations, MONEDA moneda) async {
    List<Operation> operations = new List<Operation>();

    allOperations.forEach((Operation op) {
      if (op.moneda == moneda) operations..add(op);
    });
    return operations;
  }

  static bool esConsultaDeSaldo(SmsMessage message) {
    return getTipoSms(message) == TipoSms.CONSULTAR_SALDO;
  }

  static List<Operation> smsToOperations(SmsMessage message,
      int idOperationSaldo) {
    TipoSms tipoSms = getTipoSms(message);
    List<Operation> list = new List<Operation>();

    var lines = message.body.split("\n");

    if (tipoSms == TipoSms.ULTIMAS_OPERACIONES) {
      for (int i = 2; i < lines.length - 1; i++) {
        if (lines[i].contains("INFO:")) continue;

        Operation operation = new Operation();

        var items = lines[i].split(";");
        String dateStr = items[0].trim();

        var parts = dateStr.split('/');

        DateTime date = new DateTime(int.parse(parts.elementAt(2)),
            int.parse(parts.elementAt(1)), int.parse(parts.elementAt(0)));

        operation.idOperacion = (items[5].trim()).split(" ")[0].trim();
        operation.fecha = date;
        operation.tipoOperacion = getTipoOperacion(items[1].trim());
        operation.naturaleza = getNaturalezaOperacion(items[2].trim());
        operation.moneda = getMoneda(items[4].trim());
        operation.importe = double.parse(items[3].trim());

        list.add(operation);
      }
    } else if (tipoSms == TipoSms.CONSULTAR_SALDO) {
      Operation operation = new Operation();
      operation.idOperacion = idOperationSaldo.toString();
      operation.fecha = message.date;
      operation.moneda = getMoneda(lines[2].trim().split(" ")[4].trim());
      operation.saldo = double.parse(lines[1].trim().split(" ")[3].trim());
      operation.isSaldoReal = true;
      list.add(operation);
    } else if (tipoSms == TipoSms.FACTURA_PAGADA ||
        tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      Operation operation = new Operation();
      operation.fecha = message.date;

      if (tipoSms == TipoSms.FACTURA_PAGADA) {
        operation.idOperacion = lines[3].trim().split(" ")[2].trim();
        operation.tipoOperacion = getTipoOperacion(lines[0]);
        operation.naturaleza = NaturalezaOperacion.DEBITO;
        operation.moneda = getMoneda(lines[2].trim().split(" ")[3].trim());
        operation.importe = double.parse(lines[2].trim().split(" ")[2].trim());
        operation.saldo = double.parse(lines[4].trim().split(" ")[3].trim());
        operation.isSaldoReal = true;
      } else if (tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO) {
        operation.idOperacion = lines[0].trim().split(" ")[14].trim();
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
        operation.naturaleza = NaturalezaOperacion.CREDITO;
        operation.moneda = getMoneda(lines[0].trim().split(" ")[11].trim());
        operation.importe = double.parse(lines[0].trim().split(" ")[10].trim());
      } else if (tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
        operation.idOperacion = lines[5].trim().split(" ")[2].trim();
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
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
    if (operationsSorted.length > 0) {
      operationsSorted.where((o)=>o.moneda == moneda).first.saldo = firstSaldo;
      previousSaldo = firstSaldo;
    }
    double previousImporte = 0.0;
    operationsSorted.where((o)=>o.moneda == moneda).forEach((f) {
      if (!f.isSaldoReal) {
        f.naturaleza == NaturalezaOperacion.CREDITO
            ? f.saldo = previousSaldo - previousImporte
            : f.saldo = previousSaldo + previousImporte;
      }
      previousImporte = f.importe;
      previousSaldo = f.saldo;
    });
    
    return operationsSorted;
  }

  static TipoSms getTipoSms(SmsMessage message) {
    if (message.body.contains("La consulta de saldo"))
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
    else if (message.body.contains(
        "Fallo la consulta de servicio. Para realizar esta operacion"))
      return TipoSms.ERROR_SERVICIO_SIN_AUTENTICACION;
    else if (message.body
        .contains("Fallo la consulta de las ultimas operaciones"))
      return TipoSms.ERROR_ULTIMAS_OPERACIONES;
    else if (message.body.contains("Banco Metropolitano Ultimas operaciones"))
      return TipoSms.ULTIMAS_OPERACIONES;
    else
      return TipoSms.DEFAULT;
  }

  static TipoOperacion getTipoOperacion(String cadena) {
    TipoOperacion tipoServicio = TipoOperacion.DEFAULT;
    if (cadena != null) {
      if (cadena.contains("AY"))
        tipoServicio = TipoOperacion.ATM;
      else if (cadena.contains("TELF"))
        tipoServicio = TipoOperacion.TELEFONO;
      else if (cadena.contains("TELF") || cadena.contains("telef"))
        tipoServicio = TipoOperacion.TELEFONO;
      else if (cadena.contains("ELEC") || cadena.contains("electricidad"))
        tipoServicio = TipoOperacion.ELECTRICIDAD;
      else if (cadena.contains("MULT") || cadena.contains("YY"))
        tipoServicio = TipoOperacion.MULTA;
      else if (cadena.contains("UU"))
        tipoServicio = TipoOperacion.AJUSTE;
      else if (cadena.contains("TRAN"))
        tipoServicio = TipoOperacion.TRANSFERENCIA;
      else if (cadena.contains("EV"))
        tipoServicio = TipoOperacion.SALARIO;
      else if (cadena.contains("IO"))
        tipoServicio = TipoOperacion.INTERES;
      else if (cadena.contains("AP")) tipoServicio = TipoOperacion.POS;
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
      if (cadena.contains("CUC")) moneda = MONEDA.CUC;
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

    operations.forEach((Operation operation){
      if(operation.fecha.year != year || operation.fecha.month != month){
        ResumeMonth resumenDelMes = generateResumeOperationsXMonth(listOperations);
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

    List<TipoOperacion> typeOperationsNonDuplicated = new List<TipoOperacion>.from(set);
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

      listOperations.where((o)=>o.tipoOperacion == tipoOp).forEach((f) {
        f.naturaleza == NaturalezaOperacion.DEBITO
            ? resumenTipOpDb += f.importe
            : resumenTipOpCr += f.importe;
      });

      ResumeTypeOperation typeOperation = new ResumeTypeOperation(tipoOp, resumenTipOpCr, resumenTipOpDb);
      listTypes.add(typeOperation);
    });

    ResumeMonth resumeMonth = new ResumeMonth(listOperations.first.fecha, resumenCr, resumenDb, listTypes);
    return resumeMonth;
  }
}