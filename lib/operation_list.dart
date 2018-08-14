import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_header_list/sticky_header_list.dart';

import 'operation_list_item.dart';
import 'operation.dart';

const Color monthTileBackground = Colors.white;

class OperationList extends StatelessWidget {
  final List<Operation> operaciones;
  final ScrollController hideButtonController;

  const OperationList({
    this.operaciones,
    this.hideButtonController,
  });

  /*
  bool _scrollingStarted(UserScrollNotification usn) {
    print('Wheeeeeeee!');

    if(usn.direction == ScrollDirection.reverse){
//      setState((){
        _isFABButtonVisible = false;
//      });
    }
    if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward){
//      setState((){
        _isFABButtonVisible = true;
//      });
    }

    return false;
  }
  */

  @override
  Widget build(BuildContext context) {
    List<StickyListRow> myStickyList = new List<StickyListRow>();
    generateStickyContentList(myStickyList);

    return new Scrollbar(
      child: new StickyList(
        children: myStickyList,
      ),
    );
  }

  void generateStickyContentList(List<StickyListRow> stickyList) {
    DateTime dateAnterior = operaciones.first.fecha;

    stickyList.add(
      new HeaderRow(
          child: StickyHeaderContent(
        date: dateAnterior,
      )),
    );

    operaciones.forEach((op) {
      if (op.fecha.year != dateAnterior.year ||
          op.fecha.month != dateAnterior.month) {
        dateAnterior = op.fecha;
        stickyList.add(
          new HeaderRow(
              child: StickyHeaderContent(
            date: dateAnterior,
          )),
        );
      }
      stickyList.add(
        new RegularRow(
            child: new OperationListItem(
          idOperacion: op.idOperacion,
          tipoOperacion: op.tipoOperacion,
          naturalezaOperacion: op.naturaleza,
          moneda: op.moneda,
          importe: op.importe,
          saldo: op.saldo,
          isSaldoReal: op.isSaldoReal,
          date: op.fecha,
          obs: op.observaciones,
        )),
      );
    });
  }
}

class StickyHeaderContent extends StatelessWidget {
  final DateTime date;

  const StickyHeaderContent({
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new Container(
            decoration: new BoxDecoration(color: monthTileBackground),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.date_range, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: new Text(new DateFormat('MMMM yyyy').format(date)),
                  ),
                ],
              ),
            )),
        new Divider(
          height: 0.0,
        ),
      ],
    );
  }
}
