import 'package:bankdroid/modules/contacts/components/new_contact/views/new_contact_screen.dart';
import 'package:bankdroid/modules/home/components/home/views/home_view.dart';
import 'package:bankdroid/modules/home/components/operation/views/operation_item_details.dart';
import 'package:bankdroid/modules/main/views/main_view.dart';
import 'package:bankdroid/modules/onboarding/on_boarding.dart';
import 'package:flutter/material.dart';

final routes = {
  MainView.route: (context) => MainView(),
  OnBoarding.route: (context) => OnBoarding(),
  HomePage.route: (context) => HomePage(),
  OperationItemDetails.route: (context) => OperationItemDetails(operation: ModalRoute.of(context).settings.arguments),
  NewContactScreen.route: (context) => NewContactScreen(obj: ModalRoute.of(context).settings.arguments),
};