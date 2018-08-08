

// Modelo
import 'package:flutter/rendering.dart';

import 'resumen.dart';
import 'operation.dart';

// Utils
import 'operation_list_provider.dart';
import 'ussd_methods.dart';

// Views
import 'home_tab.dart';
import 'menu_app_bar_button.dart';
import 'bottom_app_bar.dart';
import 'operation_list.dart';

// External packages
import 'package:flutter/material.dart';
import 'dart:async';

// Plugins
import 'package:permission/permission.dart';
import 'package:sms/sms.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _hideButtonController = new ScrollController();

  List<Operation> _operacionesCUP = new List<Operation>();
  List<Operation> _operacionesCUC = new List<Operation>();

  List<ResumeMonth> _resumenOperacionesCUP = new List<ResumeMonth>();
  List<ResumeMonth> _resumenOperacionesCUC = new List<ResumeMonth>();

  bool _conected = false;
  bool _loading = true;
  bool _isFABButtonVisible = true;

  bool _canReadSMS = false;
  bool _canCall = false;

  final OperationListProvider _opListProvider = new OperationListProvider();

  @override
  void initState() {
    super.initState();

    new Timer(const Duration(seconds: 3), () {
      requestPermissions([PermissionName.CallPhone,PermissionName.ReceiveSms,PermissionName.ReadSms]);
    });

    getPermission(PermissionName.ReceiveSms).then((permissionStatus){
      if(permissionStatus == PermissionStatus.allow){
        _initSMSListener();
      }
    });

    // Scroll Listener
    _initScrollListener();
  }

  Future<PermissionStatus> getPermission(PermissionName permissionName) async {
    List<Permissions> resultValue = await Permission.getPermissionStatus([permissionName]);
    return resultValue[0].permissionStatus;
  }

  requestPermissions(List<PermissionName> permissionList) async {
    if(!_loading){
      setState(() {
        _loading = true;
      });
    }
    print("Solicitar Permisos + loading...");

    List<Permissions> resultValues = await Permission.requestPermissions(permissionList);

    if(resultValues.isNotEmpty) {
      if (resultValues.any((p) => p.permissionName == PermissionName.ReadSms)) {
        if (resultValues
            .firstWhere((rv) => rv.permissionName == PermissionName.ReadSms)
            .permissionStatus == PermissionStatus.allow) {
          print("Permitir SMS");
          setState(() {
            _canReadSMS = true;
          });

          await _reloadSMSOperations();
        }
        else {
          print("No permitir SMS");
          setState(() {
            _operacionesCUC.clear();
            _operacionesCUP.clear();
            _resumenOperacionesCUC.clear();
            _resumenOperacionesCUP.clear();

            _canReadSMS = false;
            _loading = false;
          });
        }
        if(_loading && resultValues.length == 1){
          setState(() {
            _loading = false;
          });
        }
      }

      if (resultValues.any((p) =>
      p.permissionName == PermissionName.CallPhone)) {
        if (resultValues
            .firstWhere((rv) => rv.permissionName == PermissionName.CallPhone)
            .permissionStatus == PermissionStatus.allow) {
          setState(() {
            _canCall = true;
          });
        }
        else {
          setState(() {
            _canCall = false;
          });
        }
        if(_loading && resultValues.length == 1){
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  void _showSMSModal(SmsMessage msg){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(msg.address),
            content: new Text(msg.body),
          );
        });
  }

  void _initSMSListener(){
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg) {
      if (msg.address == "PAGOxMOVIL") {
        TipoSms smsType = _opListProvider.publicGetTipoSms(msg);

        if (smsType == TipoSms.AUTENTICAR) {
          _showSMSModal(msg);
          setState(() {
            _conected = true;
          });
        } else if (smsType == TipoSms.ERROR_AUTENTICACION) {
          _showSMSModal(msg);
          setState(() {
            _conected = false;
          });
        } else {
          if (smsType != TipoSms.ULTIMAS_OPERACIONES){
            _showSMSModal(msg);
          }

          if(_opListProvider.isOperationsReload(msg)) {
            setState(() {
              _loading = true;
            });

            new Timer(const Duration(seconds: 3), () {
              _operacionesCUC = new List<Operation>();
              _operacionesCUP = new List<Operation>();
              _resumenOperacionesCUC = new List<ResumeMonth>();
              _resumenOperacionesCUP = new List<ResumeMonth>();

              requestPermissions([PermissionName.ReadSms]);
              new Timer(const Duration(seconds: 5), () {
                if(_loading){
                  setState(() {
                    _loading = false;
                  });
                }
              });
            });
          }
        }
      }
    });
  }

  void _initScrollListener(){
    _hideButtonController.addListener((){
      if(_hideButtonController.position.userScrollDirection == ScrollDirection.reverse){
        setState((){
          _isFABButtonVisible = false;
        });
      }
      if(_hideButtonController.position.userScrollDirection == ScrollDirection.forward){
        setState((){
          _isFABButtonVisible = true;
        });
      }
    });
  }

  Future _reloadSMSOperations() async {
    print("Recargar Lista SMS");
    if(!_loading){
      setState(() {
        _loading = true;
      });
    }

    // Cargar la lista de mensajes
//    _opListProvider.readSms().then((messages) {
//      _opListProvider.reloadSMSOperations(messages).then(_onReloadSMSOperations);
//    });

    List<SmsMessage> listSMS = await _opListProvider.readSms();
    print("Leidos los SMS, antes de recargar las operaciones");

    List<Operation> listOperations = await _opListProvider.reloadSMSOperations(listSMS);
    print("Recargadas las operaciones, antes de cargar listas CUP y CUC");
    print("Saldo CUP: " + _opListProvider.saldoCUP.toString());
    print("Saldo CUC: " + _opListProvider.saldoCUC.toString());

    if(_conected == false) {
      if (_opListProvider.isAlreadyConected(listSMS)) {
        setState(() {
          _conected = true;
        });
      }
    }

    _onReloadSMSOperations(listOperations);
  }

  void _onReloadSMSOperations(List<Operation> operaciones) {
    if(!_loading){
      setState(() {
        _loading = true;
      });
    }
    print("Cargar listas CUP y CUC");

    _operacionesCUP = new List<Operation>();
    _operacionesCUC = new List<Operation>();


    setState(() {
      _operacionesCUP.addAll(operaciones.where((o) => o.moneda == MONEDA.CUP).toList());
      print("OnLoadedCUP_OperationList");
      _resumenOperacionesCUP = _operacionesCUP.isNotEmpty
          ? _opListProvider.getResumenOperaciones(_operacionesCUP) : new List<ResumeMonth>();
      print("OnLoadedCUP_resumenOperacionesCUP");

      _operacionesCUC.addAll(operaciones.where((o) => o.moneda == MONEDA.CUC).toList());
      print("OnLoadedCUC_OperationList");
      _resumenOperacionesCUC = _operacionesCUC.isNotEmpty
          ? _opListProvider.getResumenOperaciones(_operacionesCUC) : new List<ResumeMonth>();
      print("OnLoadedCUC_resumenOperacionesCUP");

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Llenar Tabs
    List<Widget> tabsHeader = new List<Widget>();
    List<Widget> tabsContent = new List<Widget>();
    getContent(tabsHeader, tabsContent);

    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: new AppBar(
          bottom: !_canReadSMS ? null : new TabBar(tabs: tabsHeader),
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
                      new Icon(Icons.not_interested, size: 50.0,color: Colors.black54,),
                      new Text("Sin Acceso a sus SMS"),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: new Text("Haga Click Aqui para solicitarlos nuevamente"),
                      ),
                      FloatingActionButton(
                          onPressed: (){requestPermissions([PermissionName.ReadSms]);},
                          mini: true,
                          child: new Icon(Icons.refresh,)
                      ),
                    ],
                  )
                )
              : TabBarView(children: tabsContent),
        floatingActionButton: !_canReadSMS || !_isFABButtonVisible ? null : FloatingActionButton(
          elevation: 2.0,
          onPressed: _loading ? null : _toggleConect,
          child: _conected
              ? new Icon(Icons.phonelink_erase)
              : new Icon(Icons.speaker_phone),
          backgroundColor: _loading
              ? Colors.grey
              : _conected ? Colors.lightGreen : Colors.blue,
          tooltip: _conected ? "Desconectar" : "Conectar",
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: !_isFABButtonVisible ? null : BottomAppBarWidget(
          disable: !_conected,
        ),
      ),
    );
  }

  _toggleConect() {
    if (_conected) {
      //desconectarse
      callDesconectarse();
      setState(() {
        _conected = false;
      });
    } else {
      //conectarse
      callConectarse();
      setState(() {
        _loading = true;
      });

      new Timer(const Duration(seconds: 5), () {
        setState(() {
          _loading = false;
        });
      });
    }
  }

//  _initCall(String number) async {
//    if (number != null) await new CallNumber().callNumber(number);
//  }

  void getContent(List<Widget> tabsHeader, List<Widget> tabsContent) {
    // TAB RESUMEN
    tabsHeader.add(new Tab(icon: new Icon(Icons.home),));
    tabsContent.add(HomeDashboard(
      conected: _conected,
      saldoCUP: _opListProvider.saldoCUP,
      saldoCUC: _opListProvider.saldoCUC,
      lastOperationCUP: _operacionesCUP.isNotEmpty ? _operacionesCUP[0] : null,
      lastOperationCUC: _operacionesCUC.isNotEmpty ? _operacionesCUC[0] : null,
      resumeOperationsCUP: _resumenOperacionesCUP,
      resumeOperationsCUC: _resumenOperacionesCUC,
      hideButtonController: _hideButtonController,
    ));

    // TAB CUP / CUC
    if(_operacionesCUP.isNotEmpty){
      tabsHeader.add(new Tab(text: 'CUP',));
      tabsContent.add(OperationList(
        operaciones: _operacionesCUP,
        hideButtonController: _hideButtonController,
      ));
    }
    if(_operacionesCUC.isNotEmpty){
      tabsHeader.add(new Tab(text: 'CUC',));
      tabsContent.add(OperationList(
        operaciones: _operacionesCUC,
        hideButtonController: _hideButtonController,
      ));
    }
  }
}
