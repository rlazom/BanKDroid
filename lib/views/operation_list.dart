import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:bankdroid/views/operation_list_item.dart';
import 'package:bankdroid/models/operation.dart';

const Color monthTileBackground = Colors.white;

class OperationListWdt extends StatelessWidget {
  final List<Operation> operations;

  const OperationListWdt({
    this.operations,
  });

  @override
  Widget build(BuildContext context) {
    if(operations.isEmpty){
      return new Center(
        child: new ListView(
          shrinkWrap: true,
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

    return new Scrollbar(
      child: new ListView(
        children: operations.map((op) => OperationListItem(operation: op,)).toList(),
      ),
    );
  }
}
