import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bankdroid/views/home.dart';
import 'package:bankdroid/views/on_boarding.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final String title ='BanKDroid';
  SharedPreferences prefs;
  bool _isFirstTime = true;

  Future<bool> _loadSharedPreferences() async {
    print('_loadSharedPreferences on MAIN');

    prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('is_first_time') ?? true;
//    prefs.setBool('is_first_time', false);

    return _isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: title,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: new MyHomePage(title: 'BanKDroid'),
        home: new FutureBuilder(
            future: _loadSharedPreferences(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done){
                print('is_first_time: ' + snapshot.data.toString());
                return _isFirstTime ? new OnBoarding(title: title,) : new MyHomePage(title: title,);
//                return new OnBoarding(title: title,);
              }

              return new Center(
                child: new CircularProgressIndicator(),
              );
            }
        )
    );
  }
}