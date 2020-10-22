import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.blue,
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),
    brightness: Brightness.light,
    textTheme: new TextTheme(
      headline4: TextStyle(color: Colors.black87),
      headline6: TextStyle(color: Colors.black87),
      button: TextStyle(color: Colors.black54),
      caption: TextStyle(color: Colors.black54),
      subtitle1: TextStyle(color: Colors.black54),
      bodyText1: TextStyle(color: Colors.black54),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.blue,
    iconTheme: IconThemeData(
      color: Colors.white54,
    ),
    brightness: Brightness.dark,
    textTheme: new TextTheme(
      headline4: TextStyle(color: Colors.white70),
      headline6: TextStyle(color: Colors.white70),
      button: TextStyle(color: Colors.white60),
      caption: TextStyle(color: Colors.white54),
      subtitle1: TextStyle(color: Colors.white54),
      bodyText1: TextStyle(color: Colors.white54),
    ),
  );
}
