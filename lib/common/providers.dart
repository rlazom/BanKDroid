import 'package:bankdroid/common/notifiers/device_contact_list.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:provider/provider.dart';


var providers = [
  ChangeNotifierProvider<OperationList>(create: (context) => OperationList(),),
  ChangeNotifierProvider<DeviceContactList>(create: (context) => DeviceContactList(),),
];