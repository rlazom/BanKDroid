import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:bankdroid/modules/home/components/home/views/operation_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:bankdroid/models/operation.dart';
import 'package:provider/provider.dart';

const Color monthTileBackground = Colors.white;

class OperationListWdt extends StatelessWidget {
//  final List<Operation> operations;
  final MONEDA currency;

  const OperationListWdt({
//    this.operations,
    this.currency,
  });

//  @override
//  Widget build(BuildContext context) {
//    if(operations.isEmpty){
//      return new Center(
//        child: new ListView(
//          shrinkWrap: true,
//          children: <Widget>[
//            new Icon(Icons.speaker_notes_off,color: Colors.grey,size: 40.0,),
//            Center(
//              child: new Text(
//                'Sin coincidencias',
//                style: TextStyle(color: Colors.grey,),
//              ),
//            ),
//          ],
//        ),
//      );
//    }
//
//    return new Scrollbar(
//      child: new ListView(
//        children: operations.map((op) => OperationListItem(operation: op,)).toList(),
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OperationList>(
      builder: (context, operationsProvider, child) {
        print('rebuilding Consumer Todo List Wdt');

        List list = currency == MONEDA.CUP ? operationsProvider.listCup : operationsProvider.listCuc;

        if(list.isEmpty) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new Icon(Icons.speaker_notes_off, size: 64,),
              new Text('Empty ToDo List')
            ],
          );
        }

        return Scrollbar(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ChangeNotifierProvider<Operation>.value(
                  value: list[index],
                  child: new OperationListItem()
              );
            },
          ),
        );
      },
    );
  }
}
