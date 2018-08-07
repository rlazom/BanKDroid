import 'operation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OperationListItem extends StatelessWidget {
  final String idOperacion;
  final double importe;
  final double saldo;
  final bool isSaldoReal;
  final NaturalezaOperacion naturalezaOperacion;
  final MONEDA moneda;
  final DateTime date;
  final TipoOperacion tipoOperacion;
  final String obs;

  const OperationListItem({
    this.idOperacion,
    this.importe,
    this.saldo,
    this.isSaldoReal,
    this.naturalezaOperacion,
    this.moneda,
    this.date,
    this.tipoOperacion,
    this.obs,
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> listModalContentElements = new List<Widget>();
    getModalContentList(listModalContentElements);

    return Column(
      children: [
        new ListTile(
          leading: new Icon(getIconData(tipoOperacion),
              color: Colors.grey, size: 40.0),
          title: new Text(getOperationTitle(tipoOperacion)),
          subtitle: new Text(new DateFormat('EEE, d MMM yyyy').format(date)),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              new Text(
                (naturalezaOperacion == NaturalezaOperacion.DEBITO
                        ? '-'
                        : '+') +
                    importe.toStringAsFixed(2) +
                    " " +
                    getMonedaStr(moneda),
                style: TextStyle(
                  color: getIconColor(naturalezaOperacion),
                  fontSize: 15.0,
                ),
              ),
              new Text(
                saldo.toStringAsFixed(2),
                style: TextStyle(
                  color: isSaldoReal ? Colors.black : Colors.black38,
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
                              getIconData(tipoOperacion),
                              color: getIconColor(naturalezaOperacion),
                              size: 40.0,
                            ),
                            new Text(idOperacion),
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

  void getModalContentList(List<Widget> listModalContentElements) {
    // Adding IconDate, Date and Time
    listModalContentElements.add(new Wrap(
      direction: Axis.horizontal,
      children: [
        new Icon(
          Icons.date_range,
          color: Colors.black54,
        ),
        new Text(new DateFormat('EEE, d MMM yyyy').format(date).toString()),
        new Text(', '),
        new Text(new DateFormat('h:m a').format(date).toString()),
      ],
    ));

    // Adding a blank row
    listModalContentElements.add(new Text(''));

    // Adding IconMoney, Amount and Balance
    listModalContentElements.add(new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            new Icon(
              Icons.attach_money,
              color: Colors.black54,
            ),
            new Text(importe.toStringAsFixed(2)),
            new Text(getMonedaStr(moneda)),
          ],
        ),
        Row(
          children: [
            new Text(
              saldo.toStringAsFixed(2),
              style: TextStyle(
                color: isSaldoReal ? Colors.black : Colors.black38,
              ),
            ),
            new Text(
              getMonedaStr(moneda),
              style: TextStyle(
                color: isSaldoReal ? Colors.black : Colors.black38,
              ),
            ),
          ],
        ),
      ],
    ));

    // Adding Observations (if needed)
    if (obs.length > 0) {
      listModalContentElements.add(new Text(''));
      listModalContentElements.add(new Wrap(
        direction: Axis.horizontal,
        children: [
          new Icon(
            Icons.message,
            color: Colors.black54,
          ),
          new Text(obs),
        ],
      ));
    }
  }
}
