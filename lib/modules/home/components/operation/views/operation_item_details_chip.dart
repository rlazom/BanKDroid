import 'dart:async';
import 'dart:typed_data';
import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/modules/contacts/components/new_contact/views/new_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OperationItemChip extends StatelessWidget {
  final Operation operation;

  const OperationItemChip({Key key, this.operation}) : super(key: key);

  _showSnackbar(BuildContext context, {String msg = ''}) {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: new Text(msg))
    );
  }

  _showBottomSheet({@required BuildContext context, @required String label, @required String value}) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => _buildBottomSheet(context: ctx, parentContext: context, label: label, value: value)
    );
  }

  Widget _buildBottomSheet({@required BuildContext context, @required parentContext, @required String label, @required String value}) {
    Widget bottomHeaderWdt = new Container(
        padding: EdgeInsets.all(8.0),
        color: Theme.of(context).primaryColor,
        child: Row(
          children: <Widget>[
            new Text('Asociar tarjeta a:',
            ),
          ],
        )
    );

    return new Container(
//      height: halfHeight,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Material(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bottomHeaderWdt,
            new ListTile(
              leading: new Icon(Icons.add),
              title: new Text('Nuevo Contacto'),
              onTap: () async {
                Map<String, dynamic> map = {
                  'label' : label,
                  'value' : value,
                  'operation' : operation,
                };
                Navigator.pop(context);
                var result = await Navigator.pushNamed(context, NewContactScreen.route, arguments: map);
                print('Return from New Contact - result = $result');
                if(result != null) {
                  _showSnackbar(parentContext, msg: 'Creado nuevo contacto en el dispositivo');
                }
              },
            ),
            new ListTile(
              leading: new Icon(Icons.edit),
              title: new Text('Agregar en Contacto existente'),
              onTap: (){
//          moveDeviceToARouter(router: tRouter, device: dev);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildChip(BuildContext context) {
    List<Widget> listModalContentElements = new List<Widget>();

    // Add Transfer/Service Payment associated data
    var obsArr = operation.observaciones.split(" ");
    String obsTitle = obsArr[0];
    String obsContent = obsArr[1];
    MONEDA cardType = operation.getCardType(obsContent);

    String chipText = obsContent;
    String chipCurrencyText = '';
    bool esTransf = false;
    String label;
    Uint8List thumbnail;


    if(operation.contact != null) {
      chipText = operation.contact.displayName ?? obsContent;
      label = operation.contact.getPhoneLabel(obsContent);
      thumbnail = operation.contact.avatar;
    }

    if (operation.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO ||
        operation.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
      chipCurrencyText = getMonedaStr(cardType);
      esTransf = true;
    } else {
      chipCurrencyText = operation.getOperationTitle();
    }

    if((esTransf && label?.toUpperCase() == chipCurrencyText?.toUpperCase()) || !esTransf){
      label = null;
    }

    // Adding Chip Operation Title
    listModalContentElements.add(
        new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(obsTitle),
              new Text(label ?? '',
                  style: new TextStyle(color: Colors.grey, fontSize: 12.0)
              ),
            ],
          ),
        )
    );

    // Chip Row:
    List<Widget> chipRowElements = new List<Widget>();

    // Chip Row - Button to add Card Number to Contact or Avatar
    if(thumbnail != null) {
      // IMAGEN del Avatar del Contacto
      chipRowElements.add(
          new Padding(    // IMAGEN del Avatar del Contacto
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
          )
      );
    } else {
      // CircleButton para agregar numero de tarjeta a Contactos o Inicial del Nombre del Contacto
      chipRowElements.add(
          new Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
            child: new GestureDetector(
              onTap: operation.contact != null ? null : () => _showBottomSheet(context: context, label: chipCurrencyText, value: obsContent),
//              onTap: (){},
              child: new CircleAvatar(
                maxRadius: 15.0,
                backgroundColor: Colors.grey.shade800,
                child: chipText == obsContent
                    ? new Icon(Icons.person_add, size: 18.0, color: Colors.white70,)
                    : new Text(operation.contact.getAvatarLetter(), style: TextStyle(fontSize: 16.0, color: Colors.grey,),),
              ),
            ),
          )
      );
    }


    // Adding Chip Row:: Adding Card Number or Contact Name
    chipRowElements.add(
      new Expanded(
          child: new InkWell(
              onTap: (){
                Clipboard.setData(new ClipboardData(text: obsContent));
                _showSnackbar(context, msg: 'Copiado al portapapeles: $obsContent');
                new Timer(const Duration(seconds: 3), () {
                  Scaffold.of(context).hideCurrentSnackBar();
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                child: new Text(
                  chipText,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              )
          )
      ),
    );

    // Adding Chip Row:: Adding Credit Card Icon and Currency Text CUP/CUC
    if(esTransf) {
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
    listModalContentElements.add(
        new Row(
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
        )
    );

    return Column(
      children: listModalContentElements,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildChip(context);
  }
}
