import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:simple_permissions/simple_permissions.dart';
import 'package:sms/contact.dart';
//import 'package:android_intent/android_intent.dart';

import 'permisions.dart';
import 'package:intl/intl.dart';

import 'operation.dart';
import 'package:flutter/material.dart';

const CHANNEL = const MethodChannel("cu.makkura.bankdroid/selectContacts");

Future showOperationModal(BuildContext context, Operation operation) async {

  List<Widget> listModalContentElements = await getModalContentList(context, operation);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Column(
            children: [
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(
                    getIconData(operation.tipoOperacion),
                    color: getIconColor(operation.naturaleza),
                    size: 40.0,
                  ),
                  new Text(getOperationTitle(operation.tipoOperacion)),
                ],
              ),
              new Divider(
                height: 0.0,
              ),
              new Text(
                operation.idOperacion,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black38,
                ),
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
  List<Widget> listDateTimeElements = new List<Widget>();
  String fecha = new DateFormat('EEE, d MMM yyyy').format(operation.fecha).toString();
  String hora = new DateFormat('h:m a').format(operation.fecha).toString();

  listDateTimeElements.addAll([
    new Icon(
      Icons.date_range,
      color: Colors.black54,
    ),
    new Text(fecha)
  ]);
  if(hora != '12:0 AM'){
    listDateTimeElements.add(
        new Text(', ' + hora)
    );
  }

  listModalContentElements.add(new Wrap(
    direction: Axis.horizontal,
    children: listDateTimeElements,
  ));

  // Adding a blank row
  listModalContentElements.add(new Text(''));

  // Adding Amount and Balance
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
        operation.saldo.toStringAsFixed(2) +
            " " +
            getMonedaStr(operation.moneda),
        style: TextStyle(
          color: operation.isSaldoReal ? Colors.black : Colors.black38,
        ),
      ),
    ],
  ));

  // Adding Observations (if needed)
  if (operation.observaciones.length > 0) {
    // Adding a blank row
    listModalContentElements.add(new Text(''));

    // Adding Transfer/Service Payment associated data
    var obsArr = operation.observaciones.split(" ");
    String obsTitle = obsArr[0];
    String obsContent = obsArr[1];
    bool esCUC = (obsContent.substring(0, 4) == '9202' || obsContent.substring(0, 4) == '9200');

    // Adding Chip Operation Title
    listModalContentElements.add(new Text(obsTitle));

    String chipText = obsContent;
    String chipCurrencyText = '';
    bool esTransf = false;
    Uint8List thumbnail = null;

    var readContactsPermissionStatus = await getPermission(Permission.ReadContacts);
    if (readContactsPermissionStatus == PermissionStatus.authorized) {
      Contact contact = await getContactName(operation);

      chipText = contact.fullName != null ? contact.fullName : obsContent;
      thumbnail = contact.thumbnail != null ? contact.thumbnail.bytes : null;
    }

    if (operation.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        operation.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      chipCurrencyText = esCUC ? getMonedaStr(MONEDA.CUC) : getMonedaStr(MONEDA.CUP);
      esTransf = true;
    }

    List<Widget> listModalChipElements = new List<Widget>();
    List<Widget> chipLabelRowElements = new List<Widget>();

    chipLabelRowElements.add(
      new Expanded(child: new Text(chipText)),
    );
    if(esTransf && thumbnail != null){
      chipLabelRowElements.add(
          new Stack(
            children: [
              new Icon(Icons.credit_card, size: 36.0, color: Colors.grey.shade500,),
              Padding(
                padding: const EdgeInsets.only(top: 17.0,left: 8.0),
                child: new Text(
                  chipCurrencyText,
                  style:
                  TextStyle(fontSize: 10.0, color: Colors.grey,),
                ),
              ),
            ],
          )
      );
    }

    listModalChipElements.add(
        new Expanded(
          child: new ActionChip(
            avatar: thumbnail != null
                ? Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    image: new DecorationImage(
                      image: new MemoryImage(thumbnail),
                    ),
                    borderRadius: new BorderRadius.circular(250.0),
                  ),
                )
                : new CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: esTransf
                      ? new Text(chipCurrencyText, style: TextStyle(fontSize: 10.0, color: Colors.grey,),)
                      : new Icon(Icons.confirmation_number, size: 18.0, color: Colors.white70,),
                ),
            label: Row(
              children: chipLabelRowElements,
            ),
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: obsContent));
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("Copiado al portapapeles $obsContent"),
              ));
              new Timer(const Duration(seconds: 3), () {
                Scaffold.of(context).hideCurrentSnackBar();
              });
            },
          ),
        )
    );
    if(chipText == obsContent){
      listModalChipElements.add(
          new FloatingActionButton(
            elevation: readContactsPermissionStatus == PermissionStatus.authorized ? 1.0 : 0.0,
            tooltip: "Agregar a Contactos",
            child: new Icon(Icons.person_add),
            backgroundColor: readContactsPermissionStatus == PermissionStatus.authorized ? Colors.grey.shade800 : Colors.grey,
            mini: true,
            onPressed:(){ readContactsPermissionStatus == PermissionStatus.authorized ? _createOrEditContact(obsContent,chipCurrencyText) : null;},
          )
      );
    }


    // Adding Row with Chip and Button
    listModalContentElements.add(new Row(
      children: listModalChipElements,
    ));
  }
  return listModalContentElements;
}

void _createOrEditContact(String pan, String pan_label) {

  var arguments = <String, dynamic>{
    'pan': pan,
    'pan_label': pan_label,
  };

  CHANNEL.invokeMethod("selectContacts",arguments);

}

Future getContactName(Operation operation) async {
  if (operation.observaciones.length > 0) {
    var obsArr = operation.observaciones.split(" ");
    String obsContent = obsArr[1];

    ContactQuery contacts = new ContactQuery();
    Contact contact = await contacts.queryContact(obsContent);
    if (contact.fullName != null) {
      print(contact.fullName);
    }
    return contact;
  }
}
