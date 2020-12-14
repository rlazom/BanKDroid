import 'package:bankdroid/common/theme/colors.dart';
import 'package:bankdroid/models/device_contact.dart';
import 'package:flutter/material.dart';

import '../common/enums.dart';

class Operation extends ChangeNotifier {
  String idOperacion;
  DateTime fecha;
  TipoOperacion tipoOperacion;
  TipoSms tipoSms;
  NaturalezaOperacion naturaleza;
  MONEDA moneda;
  double importe;
  double saldo;
  bool isSaldoReal;
  String observaciones;
  String fullText;
  DeviceContact contact;

  Operation() {
    this.idOperacion = '';
    this.fecha = DateTime.now();
    this.tipoOperacion = TipoOperacion.DEFAULT;
    this.tipoSms = TipoSms.DEFAULT;
    this.naturaleza = NaturalezaOperacion.DEBITO;
    this.moneda = MONEDA.CUP;
    this.importe = 0.00;
    this.saldo = -1.00;
    this.isSaldoReal = false;
    this.observaciones = '';
    this.fullText = '';
  }

  @override
  bool operator ==(other) =>
      other is Operation && other.idOperacion + other.moneda.toString() +
          other.importe.toStringAsFixed(2) ==
          idOperacion + moneda.toString() + importe.toStringAsFixed(2);

//  bool operator ==(other) => other is Operation && other.idOperacion + other.moneda.toString() + other.naturaleza.toString() + other.importe.toStringAsFixed(2) == idOperacion + moneda.toString() + naturaleza.toString() + importe.toStringAsFixed(2);

  @override
  int get hashCode {
    return idOperacion.hashCode;
  }

  static NaturalezaOperacion getNaturalezaOperacion(String cadena) {
    NaturalezaOperacion naturalezaOperacion = NaturalezaOperacion.DEBITO;
    if (cadena != null) {
      if (cadena.contains("CR"))
        naturalezaOperacion = NaturalezaOperacion.CREDITO;
    }
    return naturalezaOperacion;
  }

  static TipoOperacion getTipoOperacion(String cadena, NaturalezaOperacion naturaleza) {
    var cadenaArr = cadena.split(" ");
    String idOperacion = cadenaArr.first;
    String idTransaccion = cadenaArr[1].substring(0,2);

    TipoOperacion tipoServicio = TipoOperacion.DEFAULT;
    if (cadena != null) {
      if (idOperacion == "AY" || idTransaccion == "AY")
        tipoServicio = TipoOperacion.ATM;
      else if (idOperacion == "TELF" || cadena.contains("telef"))
        tipoServicio = TipoOperacion.TELEFONO;
      else if (idOperacion == "ELECT" || cadena.contains("electricidad"))
        tipoServicio = TipoOperacion.ELECTRICIDAD;
      else if (cadena.contains("agua"))
        tipoServicio = TipoOperacion.AGUA;
      else if (idOperacion == "RECA" || cadena.contains("recarga") || idOperacion == "MREC")
        tipoServicio = TipoOperacion.RECARGA_MOVIL;
      else if (idOperacion == "UU" || (idOperacion == "ACRED" && idTransaccion == 'EB'))
        tipoServicio = TipoOperacion.AJUSTE;
      else if (idOperacion == "YY" && idTransaccion == "YY")    // TRANSFERENCIA ATM
        tipoServicio = TipoOperacion.TRANSFERENCIA;
      else if (idOperacion == "TRAN" && idTransaccion == "MM")  // TRANSFERENCIA MOVIL
        tipoServicio = TipoOperacion.TRANSFERENCIA;
      else if (idOperacion == "MULT" && idTransaccion == "YY")
        tipoServicio = TipoOperacion.MULTA;
      else if ((idOperacion == "EV" || idTransaccion == "EV") && naturaleza == NaturalezaOperacion.CREDITO)
        tipoServicio = TipoOperacion.SALARIO;
      else if ((idOperacion == "EV" || idTransaccion == "EV") && naturaleza == NaturalezaOperacion.DEBITO)
        tipoServicio = TipoOperacion.DESCUENTO_NOMINA;
      else if (idOperacion == 'TL' || idTransaccion == 'TL')
        tipoServicio = TipoOperacion.OP_VENTANILLA;
      else if (idOperacion == "EB")
        tipoServicio = TipoOperacion.JUBILACION;
      else if (idOperacion == "IO" || idTransaccion == "IO")
        tipoServicio = TipoOperacion.INTERES;
      else if (idOperacion == "AP" || idTransaccion == "AP")
        tipoServicio = TipoOperacion.POS;
      else if (idOperacion == "AGUA" && idTransaccion == "MM")
        tipoServicio = TipoOperacion.AGUA;
      else if (idOperacion == "GAS" && idTransaccion == "MM")
        tipoServicio = TipoOperacion.GAS;
      else if (idOperacion == "CNAU" && idTransaccion == "MM")
        tipoServicio = TipoOperacion.NAUTA;
      else if ((idOperacion == "CIMX" || idOperacion == "CARI") && idTransaccion == "MM")
        tipoServicio = TipoOperacion.TU_ENVIO;
      else if (idOperacion == "ONAT" && idTransaccion == "YY")
        tipoServicio = TipoOperacion.ONAT;
      else if (idOperacion == "VIAJ" && idTransaccion == "MM")
        tipoServicio = TipoOperacion.VIAJANDO;
      else if (idOperacion == "ENZONA" ||idOperacion == "ZZ" || idTransaccion == "ZZ")
        tipoServicio = TipoOperacion.ENZONA;
    }
    if(tipoServicio == TipoOperacion.DEFAULT){
      print('NO SE ENCONTRO UNA OPERACION. idOperacion: "$idOperacion", idTransaccion: "$idTransaccion", cadena: "$cadena", naturaleza: "$naturaleza"');
    }
    return tipoServicio;
  }

  static MONEDA getMoneda(String cadena) {
    MONEDA moneda = MONEDA.CUP;
    if (cadena != null) {
      if (cadena.contains("CUC"))
        moneda = MONEDA.CUC;
    }
    return moneda;
  }

  getCardType(String cardNumber) {
    MONEDA cardType = MONEDA.CUP;
    if (cardNumber.substring(0, 4) == '9202' || cardNumber.substring(0, 4) == '9200') {
      cardType = MONEDA.CUC;
    }
    return cardType;
  }

  static Operation OperationFromSms(int idOperationSaldo, TipoSms tipoSms, DateTime smsDate, messageBody) {
    Operation operation = new Operation();
    var lines;

    operation.fecha = smsDate;
    operation.tipoSms = tipoSms;
    if (tipoSms != TipoSms.ULTIMAS_OPERACIONES) {
      lines = messageBody.split("\n");
      operation.fullText = messageBody;
    } else {
      try {
//        lines = messageBody.replaceAll('\r', '').replaceAll('|', '').split("\n")
//            .map((item) => item.trim())
//            .toList();
        lines = messageBody;
      }
      catch (e){
        print(e.toString());
      }
      // ? lines.replaceAll('\r','').split("\n").map((item) => item.trim()).toList()
      var items = lines.indexOf(';') == -1
          ? lines
          : lines.split(";");
      var parts = items[0].trim().split('/');
      DateTime date;
      try {
        date = new DateTime(
            int.parse(parts.elementAt(2)),
            int.parse(parts.elementAt(1)),
            int.parse(parts.elementAt(0))
        );
      } catch(e){
        print(e.toString());
      }
      if (date.isAfter(smsDate)) {
        date = smsDate;
      }

      operation.idOperacion = (items[5].trim()).split(" ")[0].trim();
      operation.fecha = date;
      operation.importe = double.parse(items[3].trim());
      operation.naturaleza = getNaturalezaOperacion(items[2].trim());
      operation.tipoOperacion = getTipoOperacion(
          items[1].trim() + ' ' + items[5].trim().split(" ")[0].trim(),
          operation.naturaleza);
      operation.moneda = getMoneda(items[4].trim());
    }

    if (tipoSms == TipoSms.CONSULTAR_SALDO) {
      operation.idOperacion = idOperationSaldo.toString();
      operation.tipoOperacion = TipoOperacion.SALDO;
      operation.moneda = getMoneda(lines[2].trim().split(" ")[4].trim());
      operation.saldo = double.parse(lines[1].trim().split(" ")[3].trim());
      operation.isSaldoReal = true;
    }

    if (tipoSms == TipoSms.RECARGA_MOVIL) {
      operation.idOperacion = lines[0].split(". ")[4].split(": ")[1].toString();
      operation.tipoOperacion = TipoOperacion.RECARGA_MOVIL;
      operation.importe = double.parse(lines[0].split(". ")[2].split(": ")[1].split(" ")[0].trim()).abs();
      operation.saldo = double.parse(lines[0].split(". ")[5].split(": ")[1].trim().replaceAll('CR ','')).abs();
      operation.isSaldoReal = true;

      if (lines.length > 1)  //preguntando si la recarga tiene mas de una linea para quitarle al importe el 5%
        if (lines[1].contains('descuento del 5%'))
        {
          var a = 5.0 * operation.importe / 100.0;
          operation.importe -= a;
        }

      var phoneTemp = lines[0].split(". ")[3].split(": ")[1].trim();
      if(phoneTemp.length == 8){
        phoneTemp = '+53' + phoneTemp;
      }
      operation.observaciones = "Movil: " + phoneTemp;
    }

    if (tipoSms == TipoSms.FACTURA_PAGADA ||
    tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
    tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      if (tipoSms == TipoSms.FACTURA_PAGADA) {
        operation.idOperacion = lines[3].trim().split(" ")[2].trim();
        var factura = lines[1].trim().split(": ")[1].trim();
        operation.observaciones = "Factura: " + factura;
        operation.importe = double.parse(lines[2].trim().split(" ")[2].trim());
        operation.naturaleza = NaturalezaOperacion.DEBITO;
        if(lines[0].toString().contains('Banco Metropolitano:  El pago de la factura del Gas fue completado')) {
          operation.tipoOperacion = getTipoOperacion('GAS ' + lines[3].toString().split(' ')[3].trim(), operation.naturaleza);
        } else {
          operation.tipoOperacion = getTipoOperacion(lines[0], operation.naturaleza);
        }
        operation.moneda = getMoneda(lines[2].trim().split(" ")[3].trim());
        try {
          for (String line in lines) {
            if (line.toLowerCase().contains('saldo disponible:')) {
              operation.saldo = double.parse(line.trim().split(" ")[3].trim());
              break;
            }
          }
        } catch (e) {
          print('ERROR en operation.saldo');
          operation.saldo = 0.00;
        }
        operation.isSaldoReal = true;
      }
      else if (tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO) {
        operation.idOperacion = lines[0].trim().split(" ")[14].trim();
        var cuenta = lines[0].trim().split("cuenta")[1].trim().split(" ")[0].trim();
        operation.observaciones = "Cuenta: " + cuenta;
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
        operation.naturaleza = NaturalezaOperacion.CREDITO;
        if(cuenta.substring(0,4) == '9202' || cuenta.substring(0,4) == '9200'){
          operation.moneda = MONEDA.CUC;
        }
        else{
          operation.moneda = getMoneda(lines[0].trim().split(" ")[11].trim());
        }
        operation.importe = double.parse(lines[0].trim().split(" ")[10].trim());
      }
      else if (tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
        operation.idOperacion = lines[5].trim().split(" ")[2].trim();
        var cuenta = lines[1].trim().split(" ")[1].trim();
        operation.observaciones = "Beneficiario: " + cuenta;
        operation.tipoOperacion = TipoOperacion.TRANSFERENCIA;
        operation.naturaleza = NaturalezaOperacion.DEBITO;
        operation.moneda = getMoneda(lines[3].trim().split(" ")[2].trim());
        operation.importe = double.parse(lines[3].trim().split(" ")[1].trim());
        operation.saldo = double.parse(lines[4].trim().split(" ")[3].trim());
        operation.isSaldoReal = true;
      }
    }
    return operation;
  }

  IconData getIconData() {
    return tipoOperacion == TipoOperacion.ATM ? Icons.local_atm
        : tipoOperacion == TipoOperacion.SALDO ? Icons.attach_money
        : tipoOperacion == TipoOperacion.TELEFONO ? Icons.phone
        : tipoOperacion == TipoOperacion.ELECTRICIDAD ? Icons.power
        : tipoOperacion == TipoOperacion.AGUA ? Icons.opacity
        : tipoOperacion == TipoOperacion.GAS ? Icons.whatshot
        : tipoOperacion == TipoOperacion.TU_ENVIO ? Icons.shopping_cart
        : tipoOperacion == TipoOperacion.NAUTA ? Icons.router
        : tipoOperacion == TipoOperacion.ONAT ? Icons.account_balance
        : tipoOperacion == TipoOperacion.VIAJANDO ? Icons.directions_transit
        : tipoOperacion == TipoOperacion.INTERES ? Icons.payment
        : tipoOperacion == TipoOperacion.TRANSFERENCIA ? Icons.compare_arrows
        : tipoOperacion == TipoOperacion.RECARGA_MOVIL ? Icons.phone_android
        : tipoOperacion == TipoOperacion.OP_VENTANILLA ? Icons.account_balance
        : tipoOperacion == TipoOperacion.POS ? Icons.shopping_basket
        : tipoOperacion == TipoOperacion.SALARIO ? Icons.work
        : tipoOperacion == TipoOperacion.JUBILACION ? Icons.work
        : tipoOperacion == TipoOperacion.DESCUENTO_NOMINA ? Icons.work
        : tipoOperacion == TipoOperacion.MULTA ? Icons.assignment
        : tipoOperacion == TipoOperacion.AJUSTE ? Icons.exposure
        : tipoOperacion == TipoOperacion.MISSING ? Icons.broken_image
        : tipoOperacion == TipoOperacion.ENZONA ? Icons.data_usage
        : Icons.help_outline;
  }

  Color getIconColor() {
    return naturaleza == NaturalezaOperacion.DEBITO ? kColorDebito : kColorCredito;
  }

  String getOperationTitle() {
    return tipoOperacion == TipoOperacion.ATM ? "Cajero Automatico"
        : tipoOperacion == TipoOperacion.SALDO ? "Consulta Saldo"
        : tipoOperacion == TipoOperacion.TELEFONO ? "Factura Telefonica"
        : tipoOperacion == TipoOperacion.ELECTRICIDAD ? "Factura Electrica"
        : tipoOperacion == TipoOperacion.INTERES ? "Intereses"
        : tipoOperacion == TipoOperacion.TRANSFERENCIA ? "Transferencia"
        : tipoOperacion == TipoOperacion.RECARGA_MOVIL ? "Recarga Movil"
        : tipoOperacion == TipoOperacion.OP_VENTANILLA ? "Op. Ventanilla"
        : tipoOperacion == TipoOperacion.POS ? "POS"
        : tipoOperacion == TipoOperacion.SALARIO ? "Salario"
        : tipoOperacion == TipoOperacion.JUBILACION ? "Jubilacion"
        : tipoOperacion == TipoOperacion.DESCUENTO_NOMINA ? "Descuento Nómina"
        : tipoOperacion == TipoOperacion.MULTA ? "Multa"
        : tipoOperacion == TipoOperacion.AJUSTE ? "Ajuste"
        : tipoOperacion == TipoOperacion.AGUA ? "Factura Agua"
        : tipoOperacion == TipoOperacion.GAS ? 'Factura Gas'
        : tipoOperacion == TipoOperacion.TU_ENVIO ? 'Tu Envio'
        : tipoOperacion == TipoOperacion.NAUTA ? 'Nauta'
        : tipoOperacion == TipoOperacion.ONAT ? 'ONAT'
        : tipoOperacion == TipoOperacion.VIAJANDO ? 'Viajando'
        : tipoOperacion == TipoOperacion.ENZONA ? "En Zona"
        : "Desconocido";
  }

  String getMonedaStr() {
    return moneda == MONEDA.CUP ? "CUP" : "CUC";
  }

  updateContact(DeviceContact newDeviceContact) {
    this.contact = newDeviceContact;
    notifyListeners();
  }
}