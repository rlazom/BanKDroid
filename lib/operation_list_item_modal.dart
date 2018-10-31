import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:simple_permissions/simple_permissions.dart';
import 'package:sms/contact.dart';
//import 'package:contacts_service/contacts_service.dart';

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

    // Adding Chip Row:: Loading Contacts Data
    var readContactsPermissionStatus = await getPermission(Permission.ReadContacts);
    var writeContactsPermissionStatus = await getPermission(Permission.WriteContacts);
    if (readContactsPermissionStatus == PermissionStatus.authorized) {
      Contact contact = await getContactName(operation);

      chipText = contact.fullName != null ? contact.fullName : obsContent;
      thumbnail = contact.thumbnail != null ? contact.thumbnail.bytes : null;
//      chipText = contact.displayName != null ? contact.displayName : obsContent;
//      thumbnail = contact.avatar != null ? contact.avatar : null;
    }

    if (operation.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        operation.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      chipCurrencyText = esCUC ? getMonedaStr(MONEDA.CUC) : getMonedaStr(MONEDA.CUP);
      esTransf = true;
    }

    List<Widget> chipRowElements = new List<Widget>();

    // Adding Chip Row:: Adding Button to add Card Number to Contact or Avatar
    chipRowElements.add(
      thumbnail != null
      ? new Padding(    // IMAGEN del Avatar del Contacto
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
        child: new Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            image: new DecorationImage(
              image: new MemoryImage(thumbnail),
            ),
            borderRadius: new BorderRadius.circular(250.0),
          ),
        ),
      )// IMAGEN del Avatar del Contacto
      : new Padding(    // CircleButton para agregar numero de tarjeta a Contactos o Inicial del Nombre del Contacto
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
        child: new GestureDetector(
          onTap: (){ chipText != obsContent ? null : _createOrEditContact(obsContent, chipCurrencyText, writeContactsPermissionStatus);},
          child: new CircleAvatar(
            maxRadius: 15.0,
            backgroundColor: Colors.grey.shade800,
            child: esTransf
              ? chipText == obsContent
                ? new Icon(Icons.person_add, size: 18.0, color: Colors.white70,)
                : new Text(chipText.substring(0,1), style: TextStyle(fontSize: 16.0, color: Colors.grey,),)
              : new Icon(Icons.confirmation_number, size: 18.0, color: Colors.white70,),
          ),
        ),
      )// CircleButton para agregar numero de tarjeta a Contactos o Inicial del Nombre del Contacto
    );

    // Adding Chip Row:: Adding Card Number or Contact Name
    chipRowElements.add(
      new Expanded(
          child: new InkWell(
            onTap: (){
              Clipboard.setData(new ClipboardData(text: obsContent));
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("Copiado al portapapeles $obsContent"),
              ));
              new Timer(const Duration(seconds: 3), () {
                Scaffold.of(context).hideCurrentSnackBar();
              });
            },
            child: new Text(
              chipText,
              style: TextStyle(
                  fontSize: 14.0,
              ),
            )
          )
      ),
    );

    // Adding Chip Row:: Adding Credit Card Icon and Currency Text CUP/CUC
    if(esTransf){
      chipRowElements.add(
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

    // Adding Chip Row
    listModalContentElements.add(new Row(
      children: [
        new Expanded(
            child: new Container(
              decoration: ShapeDecoration(
                  color: Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: new Row(
                  children: chipRowElements,
                ),
              ),
            )
        )
      ],
    ));
  }
  return listModalContentElements;
}

void _createOrEditContact(String pan, String pan_label, PermissionStatus writeContactsPermissionStatus) {
  if (writeContactsPermissionStatus == PermissionStatus.authorized) {
    var arguments = <String, dynamic>{
      'pan': pan,
      'pan_label': pan_label,
    };
    CHANNEL.invokeMethod("selectContacts",arguments);
  }
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

//    Iterable<Contact> contact = await ContactsService.getContacts(query : obsContent);
//    Iterable<Contact> contact = await ContactsService.getContacts(query : 'Abuela');

//    var allContacts = await ContactsService.getContacts();
//    var filtered = allContacts.where((c) => c.phones.any((phone) => phone.value.contains(obsContent))).toList();
//    if(filtered.length > 0){
//      var contact = filtered.first;
//      return contact;
//    }
  }
}
