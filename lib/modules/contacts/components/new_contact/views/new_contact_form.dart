import 'package:bankdroid/common/l10n/applocalizations.dart';
import 'package:bankdroid/modules/contacts/components/new_contact/view_model/new_contact_view_model.dart';
import 'package:bankdroid/modules/contacts/components/new_contact/views/new_contact_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';


class NewContactForm extends StatelessWidget {

  _buildForm({BuildContext context, NewContactViewModel viewModel}) {
    var localization = Localization.of(context);

    return new Padding(
      padding: const EdgeInsets.all(32.0),
      child: new ReactiveForm(
        formGroup: viewModel.form,
        child: new Column(
          children: [
            new SizedBox(height: 4.0),

            new ReactiveTextField(
              key: Key('firstName'),
              readOnly: viewModel.loading,
              formControlName: 'first_name',
              validationMessages: (control) => {
                'required': '${localization?.requiredFieldErrorMessage}',
//                'pattern': '${localization?.patternFieldErrorMessage}',
              },
//              maxLength: 8,
              cursorColor: Theme.of(context).textTheme.subtitle1.color,
              onSubmitted: () => viewModel.lastName.focus(),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
//                prefixIcon:  PrefixIcon(icon: Icon(Icons.credit_card, color: Theme.of(context).textTheme.subtitle1.color)),
//                prefixText: '*',
                prefixStyle: Theme.of(context).textTheme.subtitle1,
                labelText: '${localization?.firstNameHint}',
                hintText: '${localization.firstNameHint}',
              ),
            ),

            new SizedBox(height: 16.0),

            new ReactiveTextField(
              key: Key('lastName'),
              readOnly: viewModel.loading,
              formControlName: 'last_name',
              validationMessages: (control) => {
                'required': '${localization?.requiredFieldErrorMessage}',
//                'pattern': '${localization?.patternFieldErrorMessage}',
              },
//              maxLength: 8,
              cursorColor: Theme.of(context).textTheme.subtitle1.color,
              onSubmitted: () => viewModel.valueNumber.focus(),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
//                prefixIcon:  PrefixIcon(icon: Icon(Icons.person, color: Theme.of(context).textTheme.subtitle1.color)),
//                prefixText: '*',
                prefixStyle: Theme.of(context).textTheme.subtitle1,
                labelText: '${localization?.lastNameHint}',
                hintText: '${localization.lastNameHint}',
              ),
            ),

            new SizedBox(height: 16.0),

            new ReactiveTextField(
              key: Key('valueNumber'),
              readOnly: true,
              formControlName: 'value_number',
              validationMessages: (control) => {
                'required': '${localization?.requiredFieldErrorMessage}',
//                'pattern': '${localization?.patternFieldErrorMessage}',
              },
//              maxLength: 8,
              cursorColor: Theme.of(context).textTheme.subtitle1.color,
              onSubmitted: () => viewModel.firstName.focus(),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
//                prefixIcon:  PrefixIcon(icon: Icon(Icons.credit_card, color: Theme.of(context).textTheme.subtitle1.color)),
//                prefixText: '*',
                prefixStyle: Theme.of(context).textTheme.subtitle1,
                labelText: '${viewModel.label}',
                hintText: '${viewModel.label}',
              ),
            ),

            new SizedBox(height: 16.0),

            new NewContactSubmitButton(viewModel: viewModel,),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewContactViewModel>(
      builder: (context, viewModel, child) {
        return _buildForm(context: context, viewModel: viewModel);
      },
    );
  }
}
