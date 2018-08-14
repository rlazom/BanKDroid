import 'ussd_methods.dart';
import 'package:flutter/material.dart';

class BottomAppBarWidget extends StatelessWidget {
  final bool disable;

  const BottomAppBarWidget({
    this.disable,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      hasNotch: true,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: new Icon(
//              Icons.format_list_bulleted,
              Icons.speaker_notes,
              color: disable ? null : Colors.black87,
            ),
            tooltip: "Ultimas Operaciones",
            onPressed: disable ? null : callUltimasOperaciones,
          ),
          IconButton(
            icon: new Icon(
//              Icons.credit_card,
              Icons.credit_card,
              color: disable ? null : Colors.black87,
            ),
//            tooltip: "Operaciones",
            tooltip: "Consultar Saldo",
            onPressed: disable ? null : callSaldo,
          ),
        ],
      ),
    );
  }

//  _operaciones() {
////    _initCall("*444*70%23");
//    print("Operaciones");
//  }
}
