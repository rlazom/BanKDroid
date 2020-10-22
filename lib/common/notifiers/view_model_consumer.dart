import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewModelConsumer<T> {
  T viewModel(BuildContext context, {bool listen = false}) {
    return Provider.of<T>(context, listen: listen);
  }
}
