import 'resumen.dart';
import 'operation.dart';

import 'dart:async';
import 'package:sms/sms.dart';

class OperationListProvider {
  Future<List<SmsMessage>> ReadSms() async {
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
    Set<Operation> set = new Set<Operation>.from(operations);
    List<Operation> operationsNonDuplicated = new List<Operation>.from(set);

    // Order List elements
    List<Operation> operationsSorted = operationsNonDuplicated
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    // Agregar los saldos restantes a las operaciones
    List<Operation> operationsWithSaldo = addSaldoToOperations(operationsSorted);

    // Eliminar las operaciones de Consulta de Saldo
    operationsWithSaldo.removeWhere((op) => op.tipoOperacion == TipoOperacion.DEFAULT);

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

  static List<Operation> smsToOperations(SmsMessage message, int idOperationSaldo) {
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

  static List<Operation> addSaldoToOperations(List<Operation> operationsSorted) {
    double lastSaldoCUP = -1.0;
    double firstSaldoCUP = -1.0;
    int posFirstSaldoCUP = 0;

    double lastSaldoCUC = -1.0;
    double firstSaldoCUC = -1.0;
    int posFirstSaldoCUC = 0;

    // Recorrer la lista para actualizar los saldos restantes
    for (int i = 0; i < operationsSorted.length; i++) {
      Operation operation = operationsSorted[i];

      if (operation.isSaldoReal) {
        if(operation.moneda == MONEDA.CUP) {
          if (lastSaldoCUP == -1.0) {
            posFirstSaldoCUP = i;
            firstSaldoCUP = operation.saldo;
          }
          lastSaldoCUP = operation.saldo;
        }
        if (operation.moneda == MONEDA.CUC) {
          if (lastSaldoCUC == -1.0) {
            posFirstSaldoCUC = i;
            firstSaldoCUC = operation.saldo;
          }
          lastSaldoCUC = operation.saldo;
        }
      } else {
        if(operation.moneda == MONEDA.CUP) {
          if (operation.saldo < 0.0 && lastSaldoCUP > 0.0) {
            operation.saldo = castMoney(lastSaldoCUP);
            if (operation.naturaleza == NaturalezaOperacion.DEBITO) {
              lastSaldoCUP = castMoney(lastSaldoCUP + operation.importe);
            } else {
              lastSaldoCUP = castMoney(lastSaldoCUP - operation.importe);
            }
          }
        }
        if(operation.moneda == MONEDA.CUC) {
          if (operation.saldo < 0.0 && lastSaldoCUC > 0.0) {
            operation.saldo = castMoney(lastSaldoCUC);
            if (operation.naturaleza == NaturalezaOperacion.DEBITO) {
              lastSaldoCUC = castMoney(lastSaldoCUC + operation.importe);
            } else {
              lastSaldoCUC = castMoney(lastSaldoCUC - operation.importe);
            }
          }
        }
      }
    }

    lastSaldoCUP = firstSaldoCUP;
    for (int i = posFirstSaldoCUP; i > 0; i--) {
      Operation operation = operationsSorted[i];
      if (operation.saldo < 0.0 && operation.moneda == MONEDA.CUP) {
        if (operation.naturaleza == NaturalezaOperacion.DEBITO) {
          operation.saldo = castMoney(lastSaldoCUP - operation.importe);
        } else {
          operation.saldo = castMoney(lastSaldoCUP + operation.importe);
        }
        lastSaldoCUP = castMoney(operation.saldo);
      }
    }

    lastSaldoCUC = firstSaldoCUC;
    for (int i = posFirstSaldoCUC; i > 0; i--) {
      Operation operation = operationsSorted[i];
      if (operation.saldo < 0.0 && operation.moneda == MONEDA.CUC) {
        if (operation.naturaleza == NaturalezaOperacion.DEBITO) {
          operation.saldo = castMoney(lastSaldoCUC - operation.importe);
        } else {
          operation.saldo = castMoney(lastSaldoCUC + operation.importe);
        }
        lastSaldoCUC = castMoney(operation.saldo);
      }
    }

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
    TipoOperacion tipo_servicio = TipoOperacion.DEFAULT;
    if (cadena != null) {
      if (cadena.contains("AY"))
        tipo_servicio = TipoOperacion.ATM;
      else if (cadena.contains("TELF"))
        tipo_servicio = TipoOperacion.TELEFONO;
      else if (cadena.contains("TELF") || cadena.contains("telef"))
        tipo_servicio = TipoOperacion.TELEFONO;
      else if (cadena.contains("ELEC") || cadena.contains("electricidad"))
        tipo_servicio = TipoOperacion.ELECTRICIDAD;
      else if (cadena.contains("MULT") || cadena.contains("YY"))
        tipo_servicio = TipoOperacion.MULTA;
      else if (cadena.contains("UU"))
        tipo_servicio = TipoOperacion.AJUSTE;
      else if (cadena.contains("TRAN"))
        tipo_servicio = TipoOperacion.TRANSFERENCIA;
      else if (cadena.contains("EV"))
        tipo_servicio = TipoOperacion.SALARIO;
      else if (cadena.contains("IO"))
        tipo_servicio = TipoOperacion.INTERES;
      else if (cadena.contains("AP")) tipo_servicio = TipoOperacion.POS;
    }
    return tipo_servicio;
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

  static double castMoney(double imp){
    return (imp * 100).floor().roundToDouble()/100;
  }

  List<Object> getResumenOperaciones(List<Operation> operations,DateTime date){
    List<ResumeMonth> list = new List<ResumeMonth>();

    for(int i = 0; i <= 3; i++){
      var year = date.year;
      var month = date.month - i;
      List<Operation> listOperations = new List<Operation>();

      listOperations..addAll(operations);
      listOperations.removeWhere((op) => (op.fecha.year != year));
      listOperations.removeWhere((op) => (op.fecha.month != month));

      Set<TipoOperacion> set = new Set<TipoOperacion>();
      listOperations.forEach((Operation operation) {
        set.add(operation.tipoOperacion);
      });
      List<TipoOperacion> typeOperationsNonDuplicated = new List<TipoOperacion>.from(set);
      List<TipoOperacion> typeOperationsSorted = typeOperationsNonDuplicated
        ..sort((a, b) => getOperationTitle(a).compareTo(getOperationTitle(b)));

      double resumenDb = 0.0;
      double resumenCr = 0.0;
      listOperations.forEach((Operation operation) {
        if(operation.naturaleza == NaturalezaOperacion.DEBITO){
          resumenDb += operation.importe;
        }
        else{
          resumenCr += operation.importe;
        }
      });

      List<ResumeTypeOperation> listTypes = new List<ResumeTypeOperation>();

      typeOperationsSorted.forEach((TipoOperacion tipoOp) {
        double resumenTipOpDb = 0.0;
        double resumenTipOpCr = 0.0;
        listOperations.forEach((Operation op) {
          if(op.tipoOperacion == tipoOp){
            if(op.naturaleza == NaturalezaOperacion.DEBITO){
              resumenTipOpDb += op.importe;
            }
            else{
              resumenTipOpCr += op.importe;
            }
          }
        });
        ResumeTypeOperation typeOperation = new ResumeTypeOperation(tipoOp, resumenTipOpCr, resumenTipOpDb);
//        listTypes.add({'tipoOperacion':tipoOp,'impCre':resumenTipOpCr,'impDeb':resumenTipOpDb});
        listTypes.add(typeOperation);
      });

      ResumeMonth resumeMonth = new ResumeMonth(year,month,resumenCr,resumenDb,listTypes);
//      list.add({'year':year,'month':month,'impCre':resumenCr,'impDeb':resumenDb,'tiposOperaciones':listTypes});
      list.add(resumeMonth);
    }

    return list;
  }
}