import 'package:shared_preferences/shared_preferences.dart';
//import 'package:call_number/call_number.dart';

callConectarse() {
  _initCall("*444*40*03%23");
  print("Conectando...");
}

callDesconectarse(SharedPreferences prefs) {
  _initCall("*444*70%23");
  prefs.setBool('closed_session', true);
  print("Desconectado");
}

callSaldo() {
  _initCall("*444*46%23");
  print("Consultar Saldo");
}

callUltimasOperaciones() {
  _initCall("*444*48%23");
  print("Ultimas Operaciones");
}

_initCall(String number) async {
//  if (number != null) await new CallNumber().callNumber(number);
}