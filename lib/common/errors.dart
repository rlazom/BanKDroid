import 'package:flutter/material.dart';
import 'l10n/applocalizations.dart';

enum AppErrorValue {
  SOCKET_EXCEPTION,
  PUSH_DP_BACKEND_ERROR,
  GET_DP_BACKEND_ERROR,
}

class AppError {
  Map<String, String> _errorMap = {
    'SOCKET_EXCEPTION': 'socketExceptionErrorMessage',
    'PUSH_DP_BACKEND_ERROR': 'pushToCEErrorMessage',
    'GET_DP_BACKEND_ERROR': 'getDataFromCEErrorMessage',
  };

  String getErrorMsg(error, BuildContext context) {
    var localization = Localization.of(context);

    var errorKey = error
        .toString()
        .split('.')
        .last;
    var errorMsgKey = _errorMap[errorKey];
    return '${localization?.getValueOfKey(errorMsgKey)}';
  }
}