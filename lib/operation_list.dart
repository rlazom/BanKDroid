import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:sticky_header_list/sticky_header_list.dart';

import 'operation_list_item.dart';
import 'operation.dart';

const Color monthTileBackground = Colors.white;

class OperationList extends StatelessWidget {
  final List<Operation> operaciones;
  final ScrollController stickyListController;

  const OperationList({
    this.operaciones,
    this.stickyListController,
  });

  @override
  Widget build(BuildContext context) {
    if(operaciones.isEmpty){
      return new Center(
        child: new ListView(
          shrinkWrap: true,
          controller: stickyListController,
          children: <Widget>[
            new Icon(Icons.speaker_notes_off,color: Colors.grey,size: 40.0,),
            Center(
              child: new Text(
                'Sin coincidencias',
                style: TextStyle(color: Colors.grey,),
              ),
            ),
          ],
        ),
      );
    }

    List<StickyListRow> myStickyList = generateStickyContentList();

    return new Scrollbar(
      child: new StickyList(
        children: myStickyList,
        controller: stickyListController,
      ),
    );
  }

  List<StickyListRow> generateStickyContentList() {
    List<StickyListRow> stickyList = new List<StickyListRow>();
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
          operation: op,
        )),
      );
    });

    return stickyList;
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
