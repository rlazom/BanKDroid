import 'dart:ui';

import 'package:bankdroid/common/widgets/operation_modal_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/enums.dart';
import '../models/operation.dart';

class OperationListItem extends StatelessWidget {
  final Operation operation;

  const OperationListItem({
    this.operation,
  });

  _showOperationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(16.0),
        children: [
          OperationModalItem(operation: operation,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String localeStr = Localizations.localeOf(context).toString();
    return Column(
      children: [
        new ListTile(
          leading: new Icon(getIconData(operation.tipoOperacion),
              color: Colors.grey, size: 40.0),
          title: new Text(getOperationTitle(operation.tipoOperacion)),
          subtitle: new Text(new DateFormat('EEEE, d MMMM yyyy', localeStr).format(operation.fecha)),
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
                  fontWeight: operation.isSaldoReal ? FontWeight.bold : FontWeight.normal,
                  color: operation.isSaldoReal
                      ? Theme.of(context).textTheme.bodyText2.color
                      : Theme.of(context).textTheme.bodyText2.color.withOpacity(0.4)
                ),
              ),
            ],
          ),
//          onTap: () => showOperationModal(context, operation),
          onTap: () => _showOperationDetails(context),
        ),
        new Divider(
          height: 0.0,
        ),
      ],
    );
  }
}
