import 'package:flutter/material.dart';
import 'package:call_number/call_number.dart';

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
//          mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
//          IconButton(
//            icon: new Icon(
//              Icons.monetization_on,
//              color: disable ? null : Colors.black87,
//            ),
//            tooltip: "Consultar Saldo",
//            onPressed: disable ? null : _consultarSaldo,
//          ),
          IconButton(
            icon: new Icon(
              Icons.format_list_bulleted,
              color: disable ? null : Colors.black87,
            ),
            tooltip: "Ultimas Operaciones",
            onPressed: disable ? null : _ultimasOperaciones,
          ),
          IconButton(
            icon: new Icon(
              Icons.credit_card,
              color: disable ? null : Colors.black87,
            ),
            tooltip: "Operaciones",
            onPressed: disable ? null : _operaciones,
          ),
        ],
      ),
    );
  }

  _consultarSaldo() {
//    _initCall("*444*70%23");
    print("Consultar Saldo");
  }

  _ultimasOperaciones() {
//    _initCall("*444*70%23");
    print("Consultar Saldo");
  }

  _operaciones() {
//    _initCall("*444*70%23");
    print("Operaciones");
  }

  _transferencias() {
//    _initCall("*444*45%23");
    print("Transferencias");
  }

  _initCall(String number) async {
    if (number != null) await new CallNumber().callNumber(number);
  }
}
