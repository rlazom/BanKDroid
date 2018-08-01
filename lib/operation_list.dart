import 'package:flutter/material.dart';
import 'operation_list_item.dart';
import 'operation.dart';

class OperationList extends StatelessWidget {

  final List<Operation> operaciones;

  const OperationList({
    this.operaciones
  });

  @override
  Widget build(BuildContext context) {
    return new Scrollbar(
      child: new ListView.builder(
          padding: kMaterialListPadding,
//          padding: EdgeInsets.only(top: 2.0,bottom: -1.0),
          itemCount: operaciones.length,
          itemBuilder: (context, index) {
            //if (index.isOdd) return new Divider(height: 0.0,);
            return new OperationListItem(
              idOperacion: operaciones[index].idOperacion,
              tipoOperacion: operaciones[index].tipoOperacion,
              naturalezaOperacion: operaciones[index].naturaleza,
              moneda: operaciones[index].moneda,
              importe: operaciones[index].importe,
              saldo: operaciones[index].saldo,
              isSaldoReal: operaciones[index].isSaldoReal,
              date: operaciones[index].fecha,
            );
          }),
    );
  }
}
