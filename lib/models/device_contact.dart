import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';

class DeviceContact {
  final String displayName;
  final String givenName;
  final String company;
  final String jobTitle;
  final Iterable<Item> emails = [];
  final Iterable<Item> phones = [];
  final Contact innerContact;
  Uint8List avatar;

  DeviceContact({this.displayName, this.givenName, this.company, this.jobTitle, this.innerContact});

  String getAvatarLetter() {
    return this.displayName[0];
  }

  Future<Uint8List> getAvatar({bool photoHighRes = false}) {
    return ContactsService.getAvatar(
      this.innerContact,
      photoHighRes: photoHighRes,
    );
  }
}