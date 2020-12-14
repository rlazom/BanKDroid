import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';

class DeviceContact {
  final String displayName;
  final String givenName;
  final String company;
  final String jobTitle;
  final Iterable<Item> emails;
  final Iterable<Item> phones;
  final Contact innerContact;
  Uint8List avatar;
  bool loadedAvatar = false;

  DeviceContact({this.displayName, this.givenName, this.company, this.jobTitle, this.phones, this.emails, this.innerContact});

  String getAvatarLetter() {
    return this.displayName[0].toUpperCase();
  }

  Future updateAvatar({bool photoHighRes = false}) async {
    print('DeviceContact - updateAvatar()');
    Uint8List image = await ContactsService.getAvatar(
      this.innerContact,
      photoHighRes: photoHighRes,
    );
    avatar = image;
    loadedAvatar = true;
  }

  String getPhoneLabel(String phoneNumber) {
    return phones.firstWhere((element) => element.value == phoneNumber).label;
  }

  static DeviceContact getDeviceContactFromContact(Contact c) {
    return new DeviceContact(
      displayName: c.displayName,
      givenName: c.givenName,
      company: c.company,
      jobTitle: c.jobTitle,
      phones: c.phones,
      emails: c.emails,
      innerContact: c
    );
  }
}