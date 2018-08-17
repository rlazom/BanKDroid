import 'package:intl/intl.dart';

import 'operation.dart';
import 'package:flutter/material.dart';

void showOperationsTypeModal(BuildContext context, List<Operation> operations){
  List<Widget> listModalContentElements = getModalContentList(operations);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Column(
            children: [
              new Row(
                children: [
                  Icon(
                    getIconData(operations.first.tipoOperacion),
                    color: kDefaultIconColor,
                    size: 40.0,
                  ),
                  new Text(getOperationTitle(operations.first.tipoOperacion)),
                ],
              ),
            ],
          ),
          content: new ListView(
            shrinkWrap: true,
            children: listModalContentElements,
          ),
        );
      });
}

List<Widget> getModalContentList(List<Operation> operations) {
  List<Widget> listModalElements = new List<Widget>();
  DateTime fechaAnt = DateTime.now();

  listModalElements.add(new Text(new DateFormat('MMMM yyyy').format(operations.first.fecha),textAlign: TextAlign.end,));
  List<Operation> operationsSorted = operations..sort((a, b) => a.fecha.compareTo(b.fecha));

  operationsSorted.forEach((operation) {
    if(DateFormat('ddMMyyyy').format(operation.fecha).toString() != DateFormat('ddMMyyyy').format(fechaAnt).toString()){
      listModalElements.add(new Divider(height: 10.0,));
      listModalElements.add(new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(new DateFormat('EEEE d').format(operation.fecha).toString()),
        ],
      ));
      fechaAnt = operation.fecha;
    }
    String hora = new DateFormat('h:mm a').format(operation.fecha).toString() == '12:00 AM'
        ? ''
        : new DateFormat('h:mm a').format(operation.fecha).toString();

    listModalElements.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text(hora),
        new Text((operation.naturaleza == NaturalezaOperacion.DEBITO
            ? '-'
            : '+') +
            operation.importe.toStringAsFixed(2) + " " + getMonedaStr(operation.moneda),
          style: TextStyle(color: getIconColor(operation.naturaleza)),),
      ],
    ));
  });
  listModalElements.add(new Divider(height: 10.0,));

  return listModalElements;
}