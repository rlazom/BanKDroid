import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission/permission.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms/contact.dart';
import 'permisions.dart';

import 'operation_list_item_modal.dart';
import 'operation.dart';

class OperationListItem extends StatelessWidget {
  final Operation operation;

  const OperationListItem({
    this.operation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new ListTile(
          leading: new Icon(getIconData(operation.tipoOperacion),
              color: Colors.grey, size: 40.0),
          title: new Text(getOperationTitle(operation.tipoOperacion)),
          subtitle: new Text(new DateFormat('EEE, d MMM yyyy').format(operation.fecha)),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              new Text(
                (operation.naturaleza == NaturalezaOperacion.DEBITO
                        ? '-'
                        : '+') +
                    operation.importe.toStringAsFixed(2) +
                    " " +
                    getMonedaStr(operation.moneda),
                style: TextStyle(
                  color: getIconColor(operation.naturaleza),
                  fontSize: 15.0,
                ),
              ),
              new Text(
                operation.saldo.toStringAsFixed(2),
                style: TextStyle(
                  color: operation.isSaldoReal ? Colors.black : Colors.black38,
                ),
              ),
            ],
          ),
          onTap: () => showOperationModal(context, operation),
        ),
        new Divider(
          height: 0.0,
        ),
      ],
    );
  }
}
