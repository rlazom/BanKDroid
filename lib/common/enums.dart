import 'package:flutter/material.dart';

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
  GAS,
  MULTA,
  AJUSTE,
  POS,
  MISSING,
  ENZONA,
  TU_ENVIO,
  NAUTA,
  ONAT,
  VIAJANDO,
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
      : tipoOperacion == TipoOperacion.AGUA ? "Factura Agua"
      : tipoOperacion == TipoOperacion.GAS ? 'Factura Gas'
      : tipoOperacion == TipoOperacion.TU_ENVIO ? 'Tu Envio'
      : tipoOperacion == TipoOperacion.NAUTA ? 'Nauta'
      : tipoOperacion == TipoOperacion.ONAT ? 'ONAT'
      : tipoOperacion == TipoOperacion.VIAJANDO ? 'Viajando'
      : tipoOperacion == TipoOperacion.ENZONA ? "En Zona"
      : "Desconocido";
}

String getMonedaStr(MONEDA moneda) {
  return moneda == MONEDA.CUP ? "CUP" : "CUC";
}