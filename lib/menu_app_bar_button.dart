import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



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

  Future<Null> _aboutDialog(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must NOT tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('BanKDroid v0.0.3 beta'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: [
                new Text('Visor de Operaciones de Banco Metropolitano.\n'),
                new Text('Ayúdenos a continuar desarrollando la aplicación.'),
//                FutureBuilder<JsonObject>(
//                  future: fetchPost(),
//                  builder: (context, snapshot) {
//                    if (snapshot.hasData) {
//                      //return Text(snapshot.data.title +': '+ snapshot.data.details);
//
//                      if(snapshot.data.image!=null)
//                        {
//                          Uint8List bytes = BASE64.decode(snapshot.data.image);
//                          return ListTile(
//                              leading: new Image.memory(bytes),
//                              title: new Text(snapshot.data.title),
//                              subtitle: new Text(snapshot.data.details),);
//                        }
//                        else
//                              {
//                              return Text("no image");
//                              }
//                    } else if (snapshot.hasError) {
//                      return Text("${snapshot.error}");
//                    }
//
//                    // By default, show a loading spinner
//                    return CircularProgressIndicator();
//                  },
//                )
              ],
            ),
          ),
          actions: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                !canCall
                ? new FlatButton(
                  onPressed: requestPermissions,
                  child: new Text("Solicitar permisos", style: new TextStyle(color: Colors.blue),)
                  )
                : new FlatButton(
                  onPressed: () {_initCall("*234*1*52654732%23");},
                  child: new Text('Donar 30 centavos', style: new TextStyle(color: Colors.red),)
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<JsonObject> fetchPost() async {
    final response =
      await http.get('https://aleguerra05.now.sh/rest1');

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var responseJson = json.decode(response.body.toString());
      return new JsonObject(
          dateTime: responseJson["CUB0001"]["dateTime"],
          details: responseJson["CUB0001"]["details"],
        title: responseJson["CUB0001"]["title"],
        image: responseJson["CUB0001"]["image"]
      );
      return JsonObject.fromJson(json.decode(response.body.toString()));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  _initCall(String number) async {
    if (number != null) await new CallNumber().callNumber(number);
  }
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
