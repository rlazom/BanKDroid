import 'dart:async';

// Modelo
import 'resumen.dart';
import 'operation.dart';

// Utils
import 'operation_list_provider.dart';

// Views
import 'home_tab.dart';
import 'menu_app_bar_button.dart';
import 'bottom_app_bar.dart';
import 'operation_list.dart';

// External packages
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:call_number/call_number.dart';
import 'package:sms/sms.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Operation> _operacionesFull;
  List<Operation> _operacionesCUP;
  List<Operation> _operacionesCUC;

  List<ResumeMonth> _resumenOperacionesCUP;
  List<ResumeMonth> _resumenOperacionesCUC;

  bool _conected = false;
  bool _loading = true;
  bool _waiting = false;

  bool _canReadSMS = false;
  bool _canCall = false;

  final OperationListProvider _opListProvider = new OperationListProvider();

  @override
  void initState() {
    super.initState();
    requestPermissions([PermissionName.CallPhone, PermissionName.ReadSms, PermissionName.ReceiveSms]);
  }

  requestPermissions(List<PermissionName> permissionList) async {
    final res = await Permission.requestPermissions(permissionList).then((resultValues){

      if(resultValues.firstWhere((rv) => rv.permissionName == PermissionName.ReadSms).permissionStatus == PermissionStatus.allow){
        setState(() {
          _canReadSMS = true;
          _loading = true;
        });

        _initSMSListener();
        _reloadSMSOperations();
      }
      else{
        setState(() {
          _operacionesFull = [];
          _operacionesCUC = [];
          _operacionesCUP = [];
          _resumenOperacionesCUC = null;
          _resumenOperacionesCUP = null;

          _canReadSMS = false;
          _loading = false;
        });
      }

      if(resultValues.firstWhere((rv) => rv.permissionName == PermissionName.CallPhone).permissionStatus == PermissionStatus.allow){
        setState(() {
          _canCall = true;
        });
      }
      else{
        setState(() {
          _canCall = false;
        });
      }
    });
  }

  void _initSMSListener(){
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg) {
      if (msg.address == "PAGOxMOVIL") {
        setState(() {
          _waiting = false;
        });
        if (msg.body.contains("Usted se ha autenticado")) {
          setState(() {
            _conected = true;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text(msg.address),
                  content: new Text(msg.body),
                );
              });
        } else if (msg.body.contains("Error de autenticacion")) {
          setState(() {
            _conected = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text(msg.address),
                  content: new Text(msg.body),
                );
              });
        } else {
          setState(() {
            _loading = true;
          });
          _operacionesFull = null;
          _operacionesCUC = null;
          _operacionesCUP = null;
          _resumenOperacionesCUC = null;
          _resumenOperacionesCUP = null;
          _reloadSMSOperations();
        }
      }
    });
  }

  void _reloadSMSOperations() {
    // Cargar la lista de mensajes
    _opListProvider.readSms().then((messages) {
      _opListProvider.reloadSMSOperations(messages).then(_onReloadSMSOperations);
    });
  }

  void _onReloadSMSOperations(List<Operation> operaciones) {
    _operacionesCUP = operaciones.where((o) => o.moneda == MONEDA.CUP).toList();
    print("OnLoadedCUP_OperationList");
    _resumenOperacionesCUP = _operacionesCUP.length > 0
        ? _opListProvider.getResumenOperaciones(_operacionesCUP) : [];
    print("OnLoadedCUP_resumenOperacionesCUP");

    _operacionesCUC = operaciones.where((o) => o.moneda == MONEDA.CUC).toList();
    print("OnLoadedCUC_OperationList");
    _resumenOperacionesCUC = _operacionesCUC.length > 0
        ? _opListProvider.getResumenOperaciones(_operacionesCUC) : [];
    print("OnLoadedCUC_resumenOperacionesCUP");

    if (_operacionesCUP != null &&
        _operacionesCUC != null &&
        _resumenOperacionesCUP != null &&
        _resumenOperacionesCUC != null) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: new AppBar(
          bottom: !_canReadSMS ? null : new TabBar(tabs: [
            new Tab(
              icon: new Icon(Icons.home),
            ),
            new Tab(
              text: 'CUP',
            ),
            new Tab(
              text: 'CUC',
            ),
          ]),
          title: new Text(widget.title),
          actions: [
            MenuAppBar(
              canCall: _canCall,
              requestPermissions: (){setState(() => requestPermissions([PermissionName.CallPhone]));},
            ),
          ],
        ),
        body: _loading
            ? Center(child: new CircularProgressIndicator())
            : !_canReadSMS
              ? new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new Text("Sin Acceso a sus SMS"),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: new Text("Haga Click Aqui para solicitarlos nuevamente"),
                      ),
                      FloatingActionButton(
                          onPressed: (){requestPermissions([PermissionName.ReadSms]);},
                          child: new Icon(Icons.refresh,)
                      ),
                    ],
                  )
                )
              : TabBarView(children: [
                HomeDashboard(
                  lastOperationCUP: _operacionesCUP[0],
                  lastOperationCUC: _operacionesCUC[0],
                  resumeOperationsCUP: _resumenOperacionesCUP,
                  resumeOperationsCUC: _resumenOperacionesCUC,
                ),
                OperationList(
                  operaciones: _operacionesCUP,
                ),
                OperationList(
                  operaciones: _operacionesCUC,
                ),
              ]),
        floatingActionButton: !_canReadSMS ? null : FloatingActionButton(
          elevation: 2.0,
          onPressed: _loading || _waiting ? null : _toggleConect,
          child: _conected
              ? new Icon(Icons.phonelink_erase)
              : new Icon(Icons.speaker_phone),
          backgroundColor: _loading ||  _waiting
              ? Colors.grey
              : _conected ? Colors.lightGreen : Colors.blue,
          tooltip: _conected ? "Desconectar" : "Conectar",
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBarWidget(
          disable: !_conected,
        ),
      ),
    );
  }

  _toggleConect() {
    if (_conected) {
      //desconectarse
      _initCall("*444*70%23");
      setState(() {
        _conected = false;
      });
    } else {
      //conectarse
      _initCall("*444*40*03%23");
      setState(() {
        _waiting = true;
      });

      new Timer(const Duration(seconds: 5), () {
        setState(() {
          _waiting = false;
        });
      });
    }
  }

  _initCall(String number) async {
    if (number != null) await new CallNumber().callNumber(number);
  }
}
