import 'dart:async';

//import 'package:permission/permission.dart';
import 'package:simple_permissions/simple_permissions.dart';

Future<PermissionStatus> getPermission(Permission permission) async {

  String platformVersion =  await SimplePermissions.platformVersion;
  int mayorVersion = int.parse(platformVersion.split(' ')[1].split('.')[0]);
  print(platformVersion);
  print(mayorVersion);

  PermissionStatus resultValue = PermissionStatus.deniedNeverAsk;

  if(mayorVersion < 6) {
    resultValue = PermissionStatus.authorized;
  }
  else {
    bool checkPermissionStatus = await SimplePermissions.checkPermission(permission);
    print(checkPermissionStatus);
    if(!checkPermissionStatus) {
      if(permission == Permission.WriteContacts){
        bool checkReadContactsPermissionStatus = await SimplePermissions.checkPermission(Permission.ReadContacts);
        print(checkReadContactsPermissionStatus);
        if(checkReadContactsPermissionStatus){
          resultValue = PermissionStatus.authorized;
        }
      }
      else{
        resultValue = await SimplePermissions.requestPermission(permission);
      }
    }
    else{
      resultValue = PermissionStatus.authorized;
    }
  }
  return resultValue;
}