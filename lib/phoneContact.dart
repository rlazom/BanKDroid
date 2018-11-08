import 'dart:typed_data';

class PhoneContact{
  String name;
  String label;
  Uint8List bytes;
  String photo_uri;
  String photo_thumbnail_uri;

  /*PhoneContact(){
    this.name = '';
    this.label = '';
    this.bytes = null;
    this.photo_uri = '';
    this.photo_thumbnail_uri = '';
  }*/

  PhoneContact({this.name, this.label, this.bytes, this.photo_uri,
      this.photo_thumbnail_uri});


}