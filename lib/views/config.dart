import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import '../utils/colors.dart';
import '../utils/functions.dart';


class ConfigData extends StatefulWidget {
  ConfigData(
      {Key key, this.title, this.isFromOnBoarding, this.isFromLogin})
      : super(key: key);
  final String title;
  final bool isFromOnBoarding;
  final bool isFromLogin;

  @override
  _ConfigDataState createState() => _ConfigDataState();
}

class _ConfigDataState extends State<ConfigData> {
  SharedPreferences prefs;
  String cuentas_data_pref;
  String siglasBanco;
  List<String> siglasBancosList;

  TextEditingController _cupCtrl = new TextEditingController();
  TextEditingController _cucCtrl = new TextEditingController();

  FocusNode fnCup;
  FocusNode fnCuc;

  bool _loading = false;

  @override
  initState() {
    super.initState();
    cuentas_data_pref = '';
    siglasBanco = 'METRO';
    siglasBancosList = new List<String>();

    fnCup = new FocusNode();
    fnCuc = new FocusNode();

    _loadSharedPreferences();
  }

  @override
  void dispose() {
    _cupCtrl.dispose();
    _cucCtrl.dispose();

    fnCup.dispose();
    fnCuc.dispose();

    super.dispose();
  }

  Future _loadSharedPreferences() async {
    print('_loadSharedPreferences On Boarding');

    prefs = await SharedPreferences.getInstance();
    cuentas_data_pref = prefs.getString('cuentas_data') ?? '';
    var cnxDataJson = cuentas_data_pref != '' ? jsonDecode(cuentas_data_pref) : null;

    if (cuentas_data_pref != '') {
      if (cnxDataJson['banco'].trim() != '')
        var banco = true;
//        _cupCtrl.text = cnxDataJson['url'].trim();
      if (cnxDataJson['cup'].trim() != '')
        _cupCtrl.text = cnxDataJson['url'].trim();
      if (cnxDataJson['cuc'].trim() != '')
        _cucCtrl.text = cnxDataJson['apiKey'].trim();
    }
  }


  _SaveConexionData(BuildContext context) {
      print('_SaveConexionData()');

      String banco = 'METRO';
      String cup = _cupCtrl.text.trim();
      String cuc = _cucCtrl.text.trim();

      String cnxDataStr = '{"banco":"$banco","cup":"$cup","cuc":"$cuc"}';
      print(cnxDataStr);
      prefs.setString('conexion_data', cnxDataStr);

      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => MyHomePage(title: widget.title),
      );
      if (widget.isFromOnBoarding ?? false) {
        route = MaterialPageRoute(
          builder: (context) => MyHomePage(title: widget.title),
        );
      }
      if (widget.isFromLogin ?? false) {
        Navigator.pop(context);
        return;
      }
      Navigator.pushReplacement(
        context,
        route, //MaterialPageRoute
      );
  }


  @override
  Widget build(BuildContext context) {

    siglasBancosList.clear();
    siglasBancosList.addAll(['METRO','BPA','BANDEC']);
    List<DropdownMenuItem<String>> _dropMenuItems = siglasBancosList.map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ),
    ).toList();

    List<Widget> stackList = new List<Widget>();
//    stackList.addAll([
//      new ConstrainedBox(
//          constraints: const BoxConstraints.expand(),
//          child: new BackdropFilter(
//            filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//            child: new Container(
//              decoration:
//                  new BoxDecoration(color: Colors.black.withOpacity(0.5)),
//            ),
//          )), // DESENFOQUE
//      new ConstrainedBox(
//        constraints: const BoxConstraints.expand(),
//        child: new Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//              begin: Alignment.topCenter,
//              end: Alignment.bottomCenter,
//              stops: [0.1, 1.0],
//              colors: [
//                kSecondaryAccentDarkColor,
//                kSecondaryBackgroundDarkColor,
//              ],
//            ),
//          ),
//        ),
//      ), // DEGRADADO
//    ]);

    stackList.add(new Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 60.0, right: 60.0),
      child: new Builder(
        builder: (context) => new ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.account_balance, color: kPrimaryColor,),
                  title: new DropdownButton<String>(
                    style: TextStyle(color: kPrimaryColor,),
                    value: siglasBanco,
                    onChanged: (String newValue) {
                      setState(() {
                        siglasBanco = newValue;
                      });
                    },
                    items: _dropMenuItems,
                  ),
                ),
                new ListTile(
                  leading: new Icon(Icons.credit_card, color: kPrimaryColor,),
                  title: new TextField(
                    controller: _cupCtrl,
                    focusNode: fnCup,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(fnCuc),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    autofocus: true,
                    style: TextStyle(color: kPrimaryColor),
                    cursorColor: kPrimaryColor,
                    decoration: new InputDecoration(
                      counterStyle: TextStyle(color: kPrimaryColor),
//                    helperText: 'Teclee su numero de cuenta CUP',
                      helperStyle: TextStyle(color: kPrimaryColor,),
                      labelText: 'PAN CUP',
                      hintText: 'Número de cuenta CUP',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      hasFloatingPlaceholder: true,
                      hintStyle: new TextStyle(
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ), // CUP
                new ListTile(
                  leading: new Icon(Icons.credit_card, color: kPrimaryColor,),
                  title: new TextField(
                    controller: _cucCtrl,
                    focusNode: fnCuc,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    style: TextStyle(color: kPrimaryColor),
                    cursorColor: kPrimaryColor,
                    decoration: new InputDecoration(
                      counterStyle: TextStyle(color: kPrimaryColor),
                      labelText: 'PAN CUC',
                      hintText: 'Número de cuenta CUC',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor)),
                      hasFloatingPlaceholder: true,
                      hintStyle: new TextStyle(
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: kPrimaryColor,
                    onPressed: () {
                      _SaveConexionData(context);
                    },
                    child: new Text(
                      'Guardar y Continuar',
                      style: TextStyle(color: Colors.white70, fontSize: 18.0),
                    ),
                  ),
                ),// BTN Guardar y Continuar
              ],
            ),
      ),
    ));


    if(_loading){
      stackList.add(
        new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: new Container(
                decoration:
                new BoxDecoration(color: Colors.black.withOpacity(0.5)),
              ),
            )), // DESENFOQUE
      );
      stackList.add(
          new Center(
            child: new SizedBox(
              width: 80.0,
              height: 80.0,
              child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor.withOpacity(0.6))
              ),
            ),
          )
      );
    }

    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(
            'Configuración',
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: new OrientationBuilder(builder: (context, orientation){
//          if (orientation == Orientation.portrait){
            return new Stack(
              children: stackList,
            );
//          }
        }),
    );
  }
}

Future<Null> _reloadDataDialog(BuildContext context, bool spanish, Function reloadAllTemplatesAndData) async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: true, // user must NOT tap button!
    builder: (BuildContext localContext) {
      return new AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(spanish ? 'Recargar Todos los Datos' : 'Reload all Data'),
          ],
        ),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: [
              new Text(spanish ? 'Con esta acción perderá todos los datos de '
                  'sus rondas actuales y descargará los nuevos datos del servidor. \n\n'
                  'Desea recargar todos los datos?' : 'With this action you will lose all your '
                  'current round data.\n\n'
                  'Do you want to reload all data?', textAlign: TextAlign.justify,),
            ],
          ),
        ),
        actions: [
//          new OutlineButton(
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(30)),
//            borderSide: BorderSide(color: kPrimaryColor),
//            color: kPrimaryColor,
//            onPressed: () {
//            },
//            child: new Text(
//              spanish ? 'Cancelar' : 'Cancel',
//              style: TextStyle(color: kPrimaryColor, fontSize: 18.0),
//            ),
//          ),
          new RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            color: Colors.red,
            onPressed: (){reloadAllTemplatesAndData(context);},
            child: new Text(
              spanish ? 'Recargar' : 'Reload',
              style: TextStyle(color: Colors.white70, fontSize: 18.0),
            ),
          ),
        ],
      );
    },
  );
}