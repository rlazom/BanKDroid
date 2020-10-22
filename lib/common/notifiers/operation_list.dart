import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:flutter/material.dart';

class OperationList extends ChangeNotifier {
  List<Operation> _listCup = new List<Operation>();
  List<Operation> _listCuc = new List<Operation>();

  List<Operation> get listCup => _listCup;
  List<Operation> get listCuc => _listCuc;

  void addOperationList(List<Operation> newList) {
    this.clearAllLists();

    this._listCup.addAll(newList.where((o) => o.moneda == MONEDA.CUP).toList());
    this._listCuc.addAll(newList.where((o) => o.moneda == MONEDA.CUC).toList());

    notifyListeners();
  }

  void clearAllLists() {
    this._listCup.clear();
    this._listCuc.clear();
  }
}