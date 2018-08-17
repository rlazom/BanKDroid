import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission/permission.dart';
import 'package:sms/contact.dart';

import 'permisions.dart';
import 'package:intl/intl.dart';

import 'operation.dart';
import 'package:flutter/material.dart';

Future showOperationModal(BuildContext context, Operation operation)async {
  List<Widget> listModalContentElements = await getModalContentList(context, operation);

//  getModalContentList(context, operation).then((listModalContentElements){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Column(
              children: [
                new Row(
                  children: [
                    Icon(
                      getIconData(operation.tipoOperacion),
                      color: getIconColor(operation.naturaleza),
                      size: 40.0,
                    ),
                    new Text(operation.idOperacion),
                  ],
                ),
                new Divider(
                  height: 0.0,
                ),
              ],
            ),
            content: new ListView(
              shrinkWrap: true,
              children: listModalContentElements,
            ),
          );
        });
//  });
}

//Future getModalContentList(BuildContext context, Operation operation) async {
Future<List<Widget>> getModalContentList(BuildContext context, Operation operation) async {
  List<Widget> listModalContentElements = new List<Widget>();

  // Adding IconDate, Date and Time
  listModalContentElements.add(new Wrap(
    direction: Axis.horizontal,
    children: [
      new Icon(
        Icons.date_range,
        color: Colors.black54,
      ),
      new Text(new DateFormat('EEE, d MMM yyyy').format(operation.fecha).toString()),
      new Text(', '),
      new Text(new DateFormat('h:m a').format(operation.fecha).toString()),
    ],
  ));

  // Adding a blank row
  listModalContentElements.add(new Text(''));

  // Adding IconMoney, Amount and Balance
  listModalContentElements.add(new Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      new Text("Importe:"),
      new Text("Saldo Restante:"),
    ],
  ));
  listModalContentElements.add(new Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      new Text(operation.importe.toStringAsFixed(2)),
      new Text(
        operation.saldo.toStringAsFixed(2) + " " + getMonedaStr(operation.moneda),
        style: TextStyle(
          color: operation.isSaldoReal ? Colors.black : Colors.black38,
        ),
      ),
    ],
  ));

  // Adding Observations (if needed)
  if (operation.observaciones.length > 0) {
    listModalContentElements.add(new Text(''));

    var obsArr = operation.observaciones.split(" ");
    String obsTitle = obsArr[0];
    String obsContent = obsArr[1];
    bool esCUC = (obsContent.substring(0,4)=='9202' || obsContent.substring(0,4)=='9200');

    listModalContentElements.add(new Text(obsTitle));

    String chipText = obsContent;
    String chipCurrencyText = '';
    bool esTransf = false;

    var permissionStatus = await getPermission(PermissionName.ReadContacts);
    if(permissionStatus == PermissionStatus.allow) {
      Contact contact = await getContactName(operation);
      chipText = contact.fullName != null ? contact.fullName : obsContent;
    }

    if(operation.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO || operation.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      chipCurrencyText = esCUC ? getMonedaStr(MONEDA.CUC) : getMonedaStr(MONEDA.CUP);
      esTransf = true;
    }

    listModalContentElements.add(
        new ActionChip(
          avatar: new CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            child: esTransf ? new Text(chipCurrencyText,style: TextStyle(fontSize: 10.0, color: Colors.white70),) : new Icon(Icons.message,size: 18.0, color: Colors.white70,),
          ),
          label: new Text(chipText),
          onPressed: () {
            Clipboard.setData(new ClipboardData(text: obsContent));
            Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Copiado al portapapeles $obsContent"),));
            new Timer(const Duration(seconds: 3), () {
              Scaffold.of(context).hideCurrentSnackBar();
            });
          },
        )
    );
  }
  return listModalContentElements;
}

Future getContactName(Operation operation)async {
  if (operation.observaciones.length > 0) {
    var obsArr = operation.observaciones.split(" ");
    String obsContent = obsArr[1];

    ContactQuery contacts = new ContactQuery();
    Contact contact = await contacts.queryContact(obsContent);
    if(contact.fullName != null){
      print(contact.fullName);
    }
    return contact;
  }
}