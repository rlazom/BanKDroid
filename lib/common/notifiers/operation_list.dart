import 'package:bankdroid/models/operation.dart';
import 'package:flutter/material.dart';

class OperationList extends ChangeNotifier {
  List<Operation> _list = new List<Operation>();

  List<Operation> get list => _list;

  void addOperationList(List<Operation> newList) {
    this._list.addAll(newList);
    notifyListeners();
  }
}