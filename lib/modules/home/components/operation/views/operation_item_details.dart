import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/modules/home/components/operation/views/operation_item_details_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class OperationItemDetails extends StatelessWidget {
  static const String route = '/operation';
  final Operation operation;

  const OperationItemDetails({Key key, this.operation}) : super(key: key);

  _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 48.0, top: 8, bottom: 8),
      child: Column(
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                operation.getIconData(),
                color: operation.getIconColor(),
                size: 30.0,
              ),
              SizedBox(width: 8,),
              new Text(operation.getOperationTitle()),
            ],
          ),
          new Text(
            operation.idOperacion,
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  _buildBody(BuildContext context) {
    return new Column(
      children: [
        _buildDate(context),
        SizedBox(height: 16,),
        _buildOperationData(context),
        _buildAdditionalData(context),
      ],
    );
  }

  _buildDate(BuildContext context) {
    String localeStr = Localizations.localeOf(context).toString();

    // Adding IconDate, Date and Time
    String fecha = new DateFormat('EEEE, d MMMM yyyy', localeStr).format(operation.fecha).toString();
    String hora = new DateFormat('h:mm a').format(operation.fecha).toString();
    if(hora != '12:00 AM') {
      fecha += ', $hora';
    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Icon(
          Icons.date_range,
        ),
        new SizedBox(width: 4,),
        new Flexible(child: new Text(fecha)),
      ],
    );
  }

  _buildOperationData(BuildContext context) {
    List<Widget> listContentElements = new List();

    // Adding Amount and Balance
    listContentElements.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text("Importe:"),
            new Text("Saldo Restante:"),
          ],
        )
    );
    listContentElements.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(operation.importe.toStringAsFixed(2)),
            new Text(
              operation.saldo.toStringAsFixed(2) +
                  " " +
                  operation.getMonedaStr(),
              style: TextStyle(
                color: operation.isSaldoReal
                    ? Theme.of(context).textTheme.bodyText2.color
                    : Theme.of(context).textTheme.bodyText2.color.withOpacity(0.4),
              ),
            ),
          ],
        )
    );
    return new Column(
      children: listContentElements,
    );
  }

  _buildAdditionalData(BuildContext context) {
    if (operation.observaciones.length <= 0) {
      return Container();
    }

    // Add Additional data (if needed)
    return new Column(
      children: [
        SizedBox(height: 16,),
        OperationItemChip(operation: operation),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Operation>.value(
      value: operation,
      child: Consumer<Operation>(
        builder: (parentContext, operation, child) {
          print('rebuilding Consumer Todo List Item Toggle Item Button');

          return new Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).backgroundColor,
              title: _buildTitle(context)
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildBody(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
