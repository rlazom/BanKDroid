import 'package:flutter/material.dart';

class Operation{
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

  Operation(){
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
  bool operator ==(other) => other is Operation && other.idOperacion + other.moneda.toString() + other.importe.toStringAsFixed(2) == idOperacion + moneda.toString() + importe.toStringAsFixed(2);
//  bool operator ==(other) => other is Operation && other.idOperacion + other.moneda.toString() + other.naturaleza.toString() + other.importe.toStringAsFixed(2) == idOperacion + moneda.toString() + naturaleza.toString() + importe.toStringAsFixed(2);

  @override
  int get hashCode {
    return idOperacion.hashCode;
  }
}

const Color kColorDebito = Colors.redAccent;
const Color kColorCredito = Colors.lightGreen;
const Color kDefaultIconColor = Colors.grey;


enum TipoSms{
  CONSULTAR_ALL_ACCOUNTS,
  CONSULTAR_SALDO,
  CONSULTAR_SALDO_ERROR,
  RECARGA_MOVIL,
  TRANSFERENCIA_TX_SALDO,
  TRANSFERENCIA_RX_SALDO,
  TRANSFERENCIA_FALLIDA,
  ERROR_FACTURA,
  FACTURA,
  FACTURA_PAGADA,
  AUTENTICAR,
  INFO_CODIGO_ACTIVACION,
  ERROR_CODIGO_ACTIVACION,
  REGISTRAR_SUCESS,
  ERROR,
  ERROR_AUTENTICACION,
  ERROR_SERVICIO_SIN_AUTENTICACION,
  ERROR_ULTIMAS_OPERACIONES,
  ULTIMAS_OPERACIONES,
  DEFAULT,
}

enum TipoOperacion{
  SALARIO,
  DESCUENTO_NOMINA,
  JUBILACION,
  INTERES,
  SALDO,
  ATM,
  TRANSFERENCIA,
  RECARGA_MOVIL,
  OP_VENTANILLA,
  ELECTRICIDAD,
  TELEFONO,
  AGUA,
  MULTA,
  AJUSTE,
  POS,
  MISSING,
  DEFAULT,
}

enum NaturalezaOperacion{
  DEBITO,
  CREDITO,
}

enum MONEDA{
  CUP,
  CUC,
}


IconData getIconData(TipoOperacion tipoOperacion) {
  return tipoOperacion == TipoOperacion.ATM ? Icons.local_atm
      : tipoOperacion == TipoOperacion.SALDO ? Icons.attach_money
      : tipoOperacion == TipoOperacion.TELEFONO ? Icons.phone
      : tipoOperacion == TipoOperacion.ELECTRICIDAD ? Icons.power
      : tipoOperacion == TipoOperacion.AGUA ? Icons.opacity
      : tipoOperacion == TipoOperacion.INTERES ? Icons.payment
      : tipoOperacion == TipoOperacion.TRANSFERENCIA ? Icons.compare_arrows
      : tipoOperacion == TipoOperacion.RECARGA_MOVIL ? Icons.phone_android
      : tipoOperacion == TipoOperacion.OP_VENTANILLA ? Icons.account_balance
      : tipoOperacion == TipoOperacion.POS ? Icons.shopping_cart
      : tipoOperacion == TipoOperacion.SALARIO ? Icons.work
      : tipoOperacion == TipoOperacion.JUBILACION ? Icons.work
      : tipoOperacion == TipoOperacion.DESCUENTO_NOMINA ? Icons.work
      : tipoOperacion == TipoOperacion.MULTA ? Icons.assignment
      : tipoOperacion == TipoOperacion.AJUSTE ? Icons.exposure
      : tipoOperacion == TipoOperacion.MISSING ? Icons.broken_image
      : Icons.help_outline;
}

Color getIconColor(NaturalezaOperacion naturaleza) {
  return naturaleza == NaturalezaOperacion.DEBITO ? kColorDebito : kColorCredito;
}

String getOperationTitle(TipoOperacion tipoOperacion) {
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
      : "Desconocido";
}

String getMonedaStr(MONEDA moneda) {
  return moneda == MONEDA.CUP ? "CUP" : "CUC";
}