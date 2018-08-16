import 'dart:async';

import 'package:permission/permission.dart';

Future<PermissionStatus> getPermission(PermissionName permissionName) async {
  List<Permissions> resultValue =
  await Permission.getPermissionStatus([permissionName]);
  return resultValue[0].permissionStatus;
}