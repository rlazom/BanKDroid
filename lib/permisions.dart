import 'dart:async';

import 'package:permission/permission.dart';

Future<PermissionStatus> getPermission(PermissionName permissionName) async {

  String platformVersion =  await Permission.platformVersion;
  int mayorVersion = int.parse(platformVersion.split(' ')[1].split('.')[0]);
  List<Permissions> resultValue =[];
  print(platformVersion);
  print(mayorVersion);
  if  (mayorVersion<6) {
    resultValue.add(new Permissions(permissionName, PermissionStatus.allow));
  }
  else {
    resultValue = await Permission.getPermissionStatus([permissionName]);
  }
  return resultValue[0].permissionStatus;
}