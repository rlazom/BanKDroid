import 'dart:ui';

import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/modules/home/components/operation/views/operation_item_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class OperationListItem extends StatelessWidget {

  _showOperationDetails(BuildContext context, Operation operation) {
    Navigator.pushNamed(context, OperationItemDetails.route, arguments: operation);
  }

  @override
  Widget build(BuildContext context) {
    String localeStr = Localizations.localeOf(context).toString();

    return Consumer<Operation>(
      builder: (context, operation, child) {
        return Column(
          children: [
            new ListTile(
              leading: new Icon(operation.getIconData(),
                  color: Colors.grey, size: 40.0),
              title: new Text(operation.getOperationTitle()),
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
                        operation.getMonedaStr(),
                    style: TextStyle(
                      color: operation.getIconColor(),
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
              onTap: () => _showOperationDetails(context, operation),
            ),
            new Divider(
              height: 0.0,
            ),
          ],
        );
      },
    );
  }
}
