import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:bankdroid/models/phoneContact.dart';
import 'package:flutter/services.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_maintained/contact.dart';
import 'package:intl/intl.dart';
//import 'package:contacts_service/contacts_service.dart';

import '../utils/enums.dart';
import '../utils/permisions.dart';
import '../models/operation.dart';

const CHANNEL = const MethodChannel("cu.makkura.bankdroid/selectContacts");

Future showOperationModal(BuildContext context, Operation operation) async {
  //aki por algun motivo da una excepcion no manejada:
  /*
  I/flutter ( 2950): Another exception was thrown: RenderShrinkWrappingViewport does not support returning intrinsic dimensions.
  I/flutter ( 2950): Another exception was thrown: RenderBox was not laid out: RenderIntrinsicWidth#145f6 relayoutBoundary=up5 NEEDS-PAINT
  I/flutter ( 2950): Another exception was thrown: RenderBox was not laid out: _RenderInkFeatures#9c9c5 relayoutBoundary=up4 NEEDS-PAINT
  I/flutter ( 2950): Another exception was thrown: RenderBox was not laid out: RenderCustomPaint#1522d relayoutBoundary=up3 NEEDS-PAINT
  I/flutter ( 2950): Another exception was thrown: RenderBox was not laid out: RenderPhysicalShape#cfa65 relayoutBoundary=up2 NEEDS-PAINT
  I/flutter ( 2950): Another exception was thrown: 'package:flutter/src/rendering/shifted_box.dart': Failed assertion: line 314 pos 12: 'child.hasSize': is not true.
  I/flutter ( 2950): Another exception was thrown: RenderBox was not laid out: RenderPhysicalShape#cfa65 relayoutBoundary=up2
  */

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
          content: Text("Pendiente") /*Expanded(child: SizedBox( child: new ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context,int index){ return listModalContentElements[index];}),
          )
          )*/,
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

    String chipText = obsContent;
    String chipCurrencyText = '';
    bool esTransf = false;
    String label = null;
    Uint8List thumbnail = null;

    // Adding Chip Row:: Loading Contacts Data
//    var readContactsPermissionStatus = await getPermission(Permission.ReadContacts);
    var readContactsPermissionStatus = await getPermission(Permission.contacts);
    if (readContactsPermissionStatus == PermissionStatus.granted) {

      String phone = operation.observaciones.split(" ")[1];
      PhoneContact contact = await _findContactByPhone(phone, readContactsPermissionStatus);

      chipText = contact.name != null ? contact.name : obsContent;
      label = (contact.label != null) ? contact.label : null;
      thumbnail = contact.bytes != null ? contact.bytes : null;
    }

    if (operation.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        operation.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      chipCurrencyText = esCUC ? getMonedaStr(MONEDA.CUC) : getMonedaStr(MONEDA.CUP);
      esTransf = true;
    }
    if (operation.tipoSms == TipoSms.RECARGA_MOVIL) {
      chipCurrencyText = 'Movil';
    }
    if (operation.tipoOperacion == TipoOperacion.ELECTRICIDAD) {
      chipCurrencyText = 'Fact. Electrica';
    }
    if (operation.tipoOperacion == TipoOperacion.TELEFONO) {
      chipCurrencyText = 'Fact. Telefónica';
    }
    if (operation.tipoOperacion == TipoOperacion.AGUA) {
      chipCurrencyText = 'Fact. Agua';
    }
    if((esTransf && label == chipCurrencyText) || !esTransf){
      label = null;
    }

    // Adding Chip Operation Title
    listModalContentElements.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text(obsTitle),
        new Text(label ?? '', style: new TextStyle(
          color: Colors.grey,
          fontSize: 12.0,
        ),),
      ],
    ));

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
          onTap: (){ chipText != obsContent ? null : _createOrEditContact(obsContent, chipCurrencyText, readContactsPermissionStatus);},
          child: new CircleAvatar(
            maxRadius: 15.0,
            backgroundColor: Colors.grey.shade800,
            child: chipText == obsContent
                ? new Icon(Icons.person_add, size: 18.0, color: Colors.white70,)
                : new Text(chipText.substring(0,1), style: TextStyle(fontSize: 16.0, color: Colors.grey,),),
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
  if (writeContactsPermissionStatus == PermissionStatus.granted) {
    var arguments = <String, dynamic>{
      'pan': pan,
      'pan_label': pan_label,
    };
    CHANNEL.invokeMethod("selectContacts",arguments);
  }
}

Future _findContactByPhone(String phone, PermissionStatus readContactsPermissionStatus) async {
  if (readContactsPermissionStatus == PermissionStatus.granted) {

    // Search Contact Info by phone number
    var arguments = <String, dynamic>{
      'phone': phone,
    };
    var resultado = await CHANNEL.invokeMethod("findContactByPhone",arguments);
    if(resultado == null){
      // Si no aparece en los contactos lo busco en el Profile

      // Obtengo el Profile
      UserProfileProvider provider = new UserProfileProvider();
      UserProfile profile = await provider.getUserProfile();
      print(profile.fullName);

      if (profile == null){
        return new PhoneContact();
      }

      // Busco el numero en el Profile
      var labelFound = "";
//      profile.addresses.forEach((label,value) {
//        if (value.toString().split(" ").join() == phone) {
//          labelFound = label.toString().substring(0,5) == "label" ? null : label;
//        }
//      });

      if (labelFound == ""){
        return new PhoneContact();
      }
      PhoneContact contact = new PhoneContact(
          name: "Yo",
          label: labelFound,
          bytes: profile.thumbnail == null ? null : profile.thumbnail.bytes
      );
      return contact;
    }
    var resultadoArr = resultado.split('|');

//    var contactId = resultadoArr[0].split(": ")[1].toString().trim();
    var name = resultadoArr[1].split(": ")[1].toString().trim();
    var label = resultadoArr[2].split(": ")[1].toString().trim();
//    var photo_uri = resultadoArr[3].split(": ")[1].toString().trim();
    var photo_thumbnail_uri = resultadoArr[4].split(": ")[1].toString().trim();

    // Search Contact thumbnail by thumbnail uri
    arguments = <String, dynamic>{
      'photo_thumbnail_uri': photo_thumbnail_uri,
    };
    Uint8List bytes = await CHANNEL.invokeMethod("queryContactThumbnail",arguments);

    PhoneContact contact = new PhoneContact(
        name: name,
        label: label,
        bytes: bytes
    );

    return contact;
  }
}
