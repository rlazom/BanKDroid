import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/operation.dart';
import '../common/theme/colors.dart';
import '../common/enums.dart';

void showOperationsTypeModal(BuildContext context, List<Operation> operations){
  List<Widget> listModalContentElements = getModalContentList(context, operations);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Column(
            children: [
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Icon(
                    getIconData(operations.first.tipoOperacion),
                    color: kDefaultIconColor,
                    size: 40.0,
                  ),
                  new Text(getOperationTitle(operations.first.tipoOperacion)),
                ],
              ),
              new Divider(
                height: 0.0,
              ),
            ],
          ),
          content: new Scrollbar(
            child: new ListView(
              physics: listModalContentElements.where((w) => w.toString() != 'Divider').length > 16 ? null : NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: listModalContentElements,
            ),
          ),
        );
      });
}

List<Widget> getModalContentList(BuildContext context, List<Operation> operations) {
  List<Widget> listModalElements = new List<Widget>();
  DateTime fechaAnt = DateTime.now();
  String localeStr = Localizations.localeOf(context).toString();

  listModalElements.add(new Text(new DateFormat('MMMM yyyy', localeStr).format(operations.first.fecha),textAlign: TextAlign.end,));
  List<Operation> operationsSorted = operations..sort((a, b) => a.fecha.compareTo(b.fecha));

  operationsSorted.forEach((operation) {
    if(DateFormat('ddMMyyyy').format(operation.fecha).toString() != DateFormat('ddMMyyyy').format(fechaAnt).toString()){
      listModalElements.add(new Divider(height: 10.0,));
      listModalElements.add(new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(new DateFormat('EEEE d', localeStr).format(operation.fecha).toString()),
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