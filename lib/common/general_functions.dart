import 'package:flutter/material.dart';

void showSnackBarMsgScaffoldKey({@required scaffoldKey, @required String msg, Color color, Duration duration}) {
  scaffoldKey.currentState?.hideCurrentSnackBar();
  scaffoldKey.currentState?.showSnackBar(SnackBar(
    key: Key('scaffoldKeySnackBar'),
    content: new Text(msg),
    duration: duration != null ? duration :  new Duration(milliseconds: 3000),
    backgroundColor: color != null ? color : null,
  ));
}

String normalizeText(String rawText){
  String finalText = rawText.trim().toLowerCase();
  finalText = finalText.replaceAll('á', 'a');
  finalText = finalText.replaceAll('é', 'e');
  finalText = finalText.replaceAll('í', 'i');
  finalText = finalText.replaceAll('ó', 'o');
  finalText = finalText.replaceAll('ú', 'u');

  return finalText;
}