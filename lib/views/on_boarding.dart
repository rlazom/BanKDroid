import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'config.dart';
import '../utils/colors.dart';


class OnBoarding extends StatefulWidget {
  final String title;
  final String userId;

  const OnBoarding({Key key, this.title, this.userId}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  SharedPreferences prefs;
  bool _isFirstTime = true;

  @override
  void initState() {
    _loadSharedPreferences();
  }

  Future _loadSharedPreferences() async {
    print('_loadSharedPreferences On Boarding');

    prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('is_first_time') ?? true;
    prefs.setBool('is_first_time', false);
  }

  List fillPages() {
    //making list of pages needed to pass in IntroViewsFlutter constructor.
    var list = [
      new PageViewModel(
          pageColor: kPrimaryColor,
          bubble: new Icon(Icons.home, color: Colors.black26,),
          body: new Container(),
//          title: Text(spanish ? 'Deslice para comenzar':'Slide to continue',style: TextStyle(fontSize: 30.0, color: kPrimaryColor),),
          title: Text('Deslice para comenzar',style: TextStyle(fontSize: 30.0, color: Colors.white70),),
          mainImage: Image.asset('images/logo_apk.png', height: 285.0, width: 285.0, alignment: Alignment.center,)
//          mainImage: Image.asset('images/logo_apk.png', height: 285.0, width: 285.0,color: Colors.white70, alignment: Alignment.center,)
      ),// 0. Inicio
      new PageViewModel(
        pageColor: Colors.redAccent,
        bubble: new Icon(Icons.playlist_add_check, color: Colors.black26,),
        body: Text('Consulte el listado de sus operaciones',
          style: TextStyle(color: Colors.white70, fontSize: 18.0),),
        title: Text('Operaciones', style: TextStyle(color: Colors.white70),),
//        mainImage: Image.asset('images/sugerencias_new.png', height: 285.0, width: 285.0, alignment: Alignment.center,),
        mainImage: new Icon(Icons.playlist_add_check, color: Colors.white70, size: 200,),
        textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),// Operaciones
      new PageViewModel(
        pageColor: Colors.green,
        bubble: new Icon(Icons.attach_money, color: Colors.black26, size: 20.0,),
        body: Text('Consulte su saldo de manera intuitiva',
          style: TextStyle(color: Colors.white70, fontSize: 18.0),),
        title: Text('Saldo', style: TextStyle(color: Colors.white70),),
        mainImage: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(Icons.attach_money, color: Colors.white70, size: 150,),
          ],
        ),
        textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),// Consulte Saldo
      new PageViewModel(
        pageColor: kPrimaryColor,
        bubble: new Icon(_isFirstTime ? Icons.settings : Icons.thumb_up, color: Colors.black26,),
        body: !_isFirstTime ? new Text('') : new Text('Vamos a la configuración inicial antes de comenzar', style: TextStyle(color: Colors.white70, fontSize: 18.0),),
        title: Text('Todo Listo', style: TextStyle(color: Colors.white70),),
        mainImage: new Icon(_isFirstTime ? Icons.settings : Icons.thumb_up, size: 256.0, color: Colors.white.withOpacity(0.5),), textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),// All Set
    ];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List pages = fillPages();

    return new Builder(
      builder: (context) => IntroViewsFlutter(
        pages,
        onTapDoneButton: () {

          MaterialPageRoute route = MaterialPageRoute(builder: (context) => MyHomePage(title: widget.title),);
          if(_isFirstTime){
            route = MaterialPageRoute(builder: (context) =>
                ConfigData(
                  title: widget.title,
                  isFromOnBoarding: true,
                ),
            );
          }
          if(widget.userId != null){
            route = MaterialPageRoute(builder: (context) =>
                MyHomePage(
                  title: widget.title,
                ),
            );
          }

          Navigator.pushReplacement(
            context,
            route, //MaterialPageRoute
          );
        },
        showSkipButton: true, //Whether you want to show the skip button or not.
        skipText: new Text('Omitir'),
//        doneText: new Text(show_conexion_data ? spanish ? 'Configuración':'Configuration' : spanish ? 'Comenzar':'Start'),
        doneText: new Text(_isFirstTime ? 'Configuración' : 'Continuar'),
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ), //IntroViewsFlutter
    );
  }
}
