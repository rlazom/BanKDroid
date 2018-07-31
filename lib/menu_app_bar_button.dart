import 'dart:async';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';

class MenuAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            new PopupMenuItem<String>(
                value: 'Ayuda',
                child: new ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ayuda'),
                  onTap: () {
                    _aboutDialog(context);
                  },
                )),
          ],
    );
  }

  Future<Null> _aboutDialog(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must NOT tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('BanKDroid v0.3 beta'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text('Visor de Operaciones de Banco Metropolitano.\n'),
                new Text('Ayúdenos a continuar desarrollando la aplicación.'),
//                new Text('Envíe sus donativos al (+53)53337949'),
              ],
            ),
          ),
          actions: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new FlatButton(
                    onPressed: () {
                      _initCall("*234*1*52654732%23");
                    },
                    child: new Text(
                      'Donar 30 centavos',
                      style: new TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ],
        );
      },
    );
  }

  _initCall(String number) async {
    if (number != null) await new CallNumber().callNumber(number);
  }
}
