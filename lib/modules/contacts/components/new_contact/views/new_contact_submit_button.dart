import 'package:bankdroid/modules/contacts/components/new_contact/view_model/new_contact_view_model.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';


class NewContactSubmitButton extends StatelessWidget {
  final NewContactViewModel viewModel;

  const NewContactSubmitButton({Key key, @required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final form = ReactiveForm.of(context);
    bool isValidForm = form.valid;

    return RaisedButton(
      onPressed: (isValidForm || viewModel.loading) ? () => viewModel.saveNewContact(context) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: new Text('Save'),
    );
  }
}
