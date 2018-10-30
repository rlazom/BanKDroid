import 'dart:async';

//import 'package:permission/permission.dart';
import 'package:simple_permissions/simple_permissions.dart';

Future<PermissionStatus> getPermission(Permission permission) async {

  String platformVersion =  await SimplePermissions.platformVersion;
  int mayorVersion = int.parse(platformVersion.split(' ')[1].split('.')[0]);
  print(platformVersion);
  print(mayorVersion);

  PermissionStatus resultValue;

  if(mayorVersion < 6) {
    resultValue = PermissionStatus.authorized;
  }
  else {
    resultValue = await SimplePermissions.requestPermission(permission);
  }
  return resultValue;
}