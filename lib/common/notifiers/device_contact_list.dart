import 'package:bankdroid/models/device_contact.dart';
import 'package:flutter/material.dart';

class DeviceContactList extends ChangeNotifier {
  List<DeviceContact> _list = new List<DeviceContact>();

  List<DeviceContact> get list => _list;

  void addOperationList(List<DeviceContact> newList) {
    this._list.addAll(newList);
    notifyListeners();
  }
}