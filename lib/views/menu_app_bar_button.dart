import 'dart:async';
//import 'package:call_number/call_number.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;



class MenuAppBar extends StatelessWidget {
  final bool canCall;
  final Function requestPermissions;

  const MenuAppBar({
    this.canCall,
    this.requestPermissions,
  });

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


  Future _getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  Future<Null> _aboutDialog(BuildContext context) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String isBeta = version.substring(0,1)=='0' ? ' beta' : '';

    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must NOT tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(appName),
            ],
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text('Visor de Operaciones de Banco Metropolitano.'),
              ],
            ),
          ),
          actions: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                new Text('version ' + version + isBeta),
              ],
            ),
          ],
        );
      },
    );
  }

//  _initCall(String number) async {
//    if (number != null) await new CallNumber().callNumber(number);
//  }
}

class JsonObject{
  final String title;
  final String details;
  final String image;
  final String dateTime;

  JsonObject({this.title, this.details, this.image, this.dateTime});

  factory JsonObject.fromJson(Map<String, dynamic> json){
    return new JsonObject(
      title: json['title'],
      details: json['details'],
      image: json['image'],
      dateTime: json['dateTime'],
    );
  }


}
