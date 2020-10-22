import '../common/enums.dart';

class Operation {
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

  NaturalezaOperacion getNaturalezaOperacion(String cadena) {
    NaturalezaOperacion naturalezaOperacion = NaturalezaOperacion.DEBITO;
    if (cadena != null) {
      if (cadena.contains("CR"))
        naturalezaOperacion = NaturalezaOperacion.CREDITO;
    }
    return naturalezaOperacion;
  }

  TipoOperacion getTipoOperacion(String cadena, NaturalezaOperacion naturaleza) {
    String idOperacion = cadena.split(" ")[0];
    String idTransaccion = cadena.split(" ")[1].substring(0,2);

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
      else if (idOperacion == "UU")
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
      else if (idOperacion == "TL")
        tipoServicio = TipoOperacion.OP_VENTANILLA;
      else if (idOperacion == "EB")
        tipoServicio = TipoOperacion.JUBILACION;
      else if (idOperacion == "IO" || idTransaccion == "IO")
        tipoServicio = TipoOperacion.INTERES;
      else if (idOperacion == "AP" || idTransaccion == "AP")
        tipoServicio = TipoOperacion.POS;
      else if (idOperacion == "AGUA" && idTransaccion == "MM")
        tipoServicio = TipoOperacion.AGUA;
      else if (idOperacion == "ENZONA" ||idOperacion == "ZZ" || idTransaccion == "ZZ")
        tipoServicio = TipoOperacion.ENZONA;
    }
    if(tipoServicio == TipoOperacion.DEFAULT){
      print('NO SE ENCONTRO UNA OPERACION. $cadena $naturaleza');
    }
    return tipoServicio;
  }

  MONEDA getMoneda(String cadena) {
    MONEDA moneda = MONEDA.CUP;
    if (cadena != null) {
      if (cadena.contains("CUC"))
        moneda = MONEDA.CUC;
    }
    return moneda;
  }

  Operation OperationFromSms(int idOperationSaldo, TipoSms tipoSms, DateTime smsDate, messageBody) {
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
        var a = e;
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
        var a = e;
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
        operation.tipoOperacion = getTipoOperacion(lines[0], operation.naturaleza);
        operation.moneda = getMoneda(lines[2].trim().split(" ")[3].trim());
        operation.saldo = double.parse(lines[4].trim().split(" ")[3].trim());
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
}