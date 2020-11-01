import 'package:flutter/material.dart';


void showSnackBarMsg(BuildContext context, String msg) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(milliseconds: 3000),
  ));
}