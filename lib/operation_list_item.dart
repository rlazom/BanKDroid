import 'dart:async';
import 'dart:typed_data';

import 'permisions.dart';
import 'package:flutter/services.dart';
import 'package:permission/permission.dart';

import 'operation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms/contact.dart';

class OperationListItem extends StatelessWidget {
  final Operation operacion;

  const OperationListItem({
    this.operacion,
  });

  @override
  Widget build(BuildContext context) {

//    getUser();

    List<Widget> listModalContentElements = new List<Widget>();
    getModalContentList(listModalContentElements, context);

    return Column(
      children: [
        new ListTile(
          leading: new Icon(getIconData(operacion.tipoOperacion),
              color: Colors.grey, size: 40.0),
          title: new Text(getOperationTitle(operacion.tipoOperacion)),
          subtitle: new Text(new DateFormat('EEE, d MMM yyyy').format(operacion.fecha)),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              new Text(
                (operacion.naturaleza == NaturalezaOperacion.DEBITO
                        ? '-'
                        : '+') +
                    operacion.importe.toStringAsFixed(2) +
                    " " +
                    getMonedaStr(operacion.moneda),
                style: TextStyle(
                  color: getIconColor(operacion.naturaleza),
                  fontSize: 15.0,
                ),
              ),
              new Text(
                operacion.saldo.toStringAsFixed(2),
                style: TextStyle(
                  color: operacion.isSaldoReal ? Colors.black : Colors.black38,
                ),
              ),
            ],
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: Column(
                      children: [
                        new Row(
                          children: [
                            Icon(
                              getIconData(operacion.tipoOperacion),
                              color: getIconColor(operacion.naturaleza),
                              size: 40.0,
                            ),
                            new Text(operacion.idOperacion),
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
          },
        ),
        new Divider(
          height: 0.0,
        ),
      ],
    );
  }

  Future getContactName()async {
    if (operacion.observaciones.length > 0) {
      var obsArr = operacion.observaciones.split(" ");
      String obsContent = obsArr[1];

      ContactQuery contacts = new ContactQuery();
      Contact contact = await contacts.queryContact(obsContent);
      if(contact.fullName != null){
        print(contact.fullName);
      }
      return contact;
    }
  }

  Future getModalContentList(List<Widget> listModalContentElements, BuildContext context) async {
    // Adding IconDate, Date and Time
    listModalContentElements.add(new Wrap(
      direction: Axis.horizontal,
      children: [
        new Icon(
          Icons.date_range,
          color: Colors.black54,
        ),
        new Text(new DateFormat('EEE, d MMM yyyy').format(operacion.fecha).toString()),
        new Text(', '),
        new Text(new DateFormat('h:m a').format(operacion.fecha).toString()),
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
        Row(
          children: [
//            new Icon(
//              Icons.attach_money,
//              color: Colors.black54,
//            ),
            new Text(operacion.importe.toStringAsFixed(2)),
            new Text(getMonedaStr(operacion.moneda),style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        ),
        Row(
          children: [
            new Text(
              operacion.saldo.toStringAsFixed(2),
              style: TextStyle(
                color: operacion.isSaldoReal ? Colors.black : Colors.black38,
              ),
            ),
            new Text(
              getMonedaStr(operacion.moneda),
              style: TextStyle(
                color: operacion.isSaldoReal ? Colors.black : Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ));

    // Adding Observations (if needed)
    if (operacion.observaciones.length > 0) {
      listModalContentElements.add(new Text(''));

      var obsArr = operacion.observaciones.split(" ");
      String obsTitle = obsArr[0];
      String obsContent = obsArr[1];
      bool esCUC = (obsContent.substring(0,4)=='9202' || obsContent.substring(0,4)=='9200');

      listModalContentElements.add(new Text(obsTitle));

      String chipText = obsContent;
      String chipCurrencyText = '';
      bool esTransf = false;

      var permissionStatus = await getPermission(PermissionName.ReadContacts);
      if(permissionStatus == PermissionStatus.allow) {
        Contact contact = await getContactName();
        chipText = contact.fullName != null ? contact.fullName : obsContent;
      }

      if(operacion.tipoSms == TipoSms.TRANSFERENCIA_RX_SALDO || operacion.tipoSms == TipoSms.TRANSFERENCIA_TX_SALDO) {
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
  }
}
