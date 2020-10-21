import 'dart:async';

//import 'package:permission/permission.dart';
import 'package:permission_handler/permission_handler.dart';

Future<PermissionStatus> getPermission(Permission permission) async {
  return await permission.request();
}