import 'package:bankdroid/common/notifiers/loader_state.dart';
import 'package:bankdroid/models/device_contact.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class NewContactViewModel extends LoaderViewModel {
  final obj;
  String label;
  String value;
  Operation operation;

  NewContactViewModel({this.obj}) {
    label = this.obj['label'];
    value = this.obj['value'];
    operation = this.obj['operation'];
    setValueNumber(value);
  }

  final form = FormGroup({
    'first_name': FormControl(value: '', validators: [Validators.required]),
    'last_name': FormControl(value: ''),
    'value_number': FormControl(value: '', validators: [Validators.required]),
  });

  FormControl get firstName => this.form.control('first_name');
  FormControl get lastName => this.form.control('last_name');
  FormControl get valueNumber => this.form.control('value_number');

  setFirstName(String newValue) => this.form.control('first_name').value = newValue;
  setLastName(String newValue) => this.form.control('last_name').value = newValue;
  setValueNumber(String newValue) => this.form.control('value_number').value = newValue;

  Future saveNewContact(BuildContext context) async {
    print('NewContactViewModel - saveNewContact()');
    this.markAsLoading();

    String firstNameStr = this.firstName.value ?? '';
    String lastNameStr = this.lastName.value ?? '';

    Contact newContact = new Contact(
      givenName: firstNameStr,
      displayName: firstNameStr,
      familyName: lastNameStr,
      phones: [Item(label: label, value: value)]
    );

    try {
      await ContactsService.addContact(newContact);
    } catch (e) {
      print('LoginViewModel - processLogin() Exception: $e');
      this.markAsFailed(error: e);
      return;
    }

    DeviceContact newDeviceContact = DeviceContact.getDeviceContactFromContact(newContact);
    operation.updateContact(newDeviceContact);

    Navigator.pop(context, true);
  }
}