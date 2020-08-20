import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:battery/battery.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:location/location.dart';

const CHANNEL = const MethodChannel("cu.makkura.rondas/myChannels");

DateTime formatDateTime(String timeToFormat) {
  DateTime finalDateTime = null;
  var arr = [];
  if(timeToFormat != null) {
    arr = timeToFormat.split(" ");
  }
  if(arr.isNotEmpty && arr.join().trim().length > 0) {
    if(arr.length == 1) {
      arr = timeToFormat.split("-");
      finalDateTime = new DateTime(int.parse(arr[0]), int.parse(arr[1]), int.parse(arr[2]));
    }
    else{
      var fecha = arr[0].split("-");
      var hora = arr[1].split(":");
      finalDateTime = new DateTime(int.parse(fecha[0]), int.parse(fecha[1]), int.parse(fecha[2]), int.parse(hora[0]), int.parse(hora[1]), int.parse(hora[2]));
    }
  }
  return finalDateTime;
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

File getLocalFile(String filename) {
//  String dir = await _localPath;
  return new File(filename);
}

List getArrFromStr(String arrStr){
  return arrStr.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '').split(',');
}

DateTime getDateTimeFromStrTime(String dow, String ht){
  DateTime dtNow = new DateTime.now();

  DateTime dtTemp;
//  var i = 1;
//  DateTime dtTemp = DateTime(dtNow.year,dtNow.month,dtNow.day);
//  while(new DateFormat('EEEE').format(dtTemp).toLowerCase() != dow){
//    dtTemp = dtTemp.add(new Duration(days: i));
//    i++;
//  }
  for(var i = 0; i < 10; i++){
    dtTemp = dtNow.add(Duration(days: i));
    if(new DateFormat('EEEE').format(dtTemp).toLowerCase() == dow){
      break;
    }
  }

  int hour = int.parse(ht.split(":")[0]);
  int minutes = int.parse(ht.split(":")[1]);

  return new DateTime(dtTemp.year, dtTemp.month, dtTemp.day, hour, minutes);
}

Future<File> deleteLocalFile(String filename) async {
  File f = new File(filename);
  return f.delete();
}

void showSnackBarMsg(BuildContext context, String msg) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(milliseconds: 3000),
  ));
}

void vibratePhone(){
  CHANNEL.invokeMethod("vibrateFunction", null);
}

//void _showMessageModal(BuildContext context, String title, String body) {
//  showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        return new AlertDialog(
//          title: new Text(title),
//          content: new Text(body),
//        );
//      });
//}

Future<String> getConexionData(String key) async {
  print('getConexionData(key: $key)');

  var prefs = await SharedPreferences.getInstance();
  var cnxDataStr = prefs.getString('conexion_data') ?? true;

  if(cnxDataStr == true){
    return '';
  }
  var cnxDataJson = jsonDecode(cnxDataStr);
  var keyData = cnxDataJson[key];

  return keyData;
}