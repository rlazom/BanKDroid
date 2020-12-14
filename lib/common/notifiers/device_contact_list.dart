import 'package:bankdroid/models/device_contact.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class DeviceContactList extends ChangeNotifier {
  List<DeviceContact> _list = new List<DeviceContact>();

  List<DeviceContact> get list => _list;

  Future<void> loadDeviceContactList() async {
    print('DeviceContactList - loadDeviceContactList()');

    this._list.clear();
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    this._list = contacts.map((Contact e) => DeviceContact.getDeviceContactFromContact(e)).toList();
    print('_list.length = ${_list.length}');
    notifyListeners();
  }

  DeviceContact getDeviceContactWithPhoneNumber({String phoneNumber}) {
    print('getDeviceContactWithPhoneNumber($phoneNumber)');
    return this._list.firstWhere((contact) => contact.phones.any((phone) => phone?.value == phoneNumber), orElse: () => null);
  }

  openContactForm() {
    ContactsService.openContactForm();
  }
}