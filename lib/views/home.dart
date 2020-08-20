import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';
//--------------------------------
import '../models/operation.dart';
import '../utils/enums.dart';
import '../utils/operation_list_provider.dart';
import '../utils/ussd_methods.dart';
import '../utils/permisions.dart';
import '../models/resumen.dart';
import 'resume_tab.dart';
import 'menu_app_bar_button.dart';
import 'operation_list.dart';

// External packages


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyCup = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyCuc = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;

  ScrollController _hideButtonController = new ScrollController();
  ScrollController _stickyScrollController = new ScrollController();
  TextEditingController filterCtrl = new TextEditingController();
  TabController tabController;

  String filter;

  List<Operation> _operacionesCUP = new List<Operation>();
  List<Operation> _operacionesCUC = new List<Operation>();
  List<Operation> _filteredCUP = new List<Operation>();
  List<Operation> _filteredCUC = new List<Operation>();

  List<ResumeMonth> _resumenOperacionesCUP = new List<ResumeMonth>();
  List<ResumeMonth> _resumenOperacionesCUC = new List<ResumeMonth>();

  bool _isSearch = false;

  bool _conected = false;
  bool _loading = true;
  bool _isFABButtonVisible = true;

  bool _canReadSMS = false;
  bool _canCall = false;

  final OperationListProvider _opListProvider = new OperationListProvider();

  @override
  void initState() {
    super.initState();

    _loadSharedPreferences();

    new Timer(const Duration(seconds: 3), () {
      requestPermissions([
        Permission.CallPhone,
        Permission.ReceiveSms,
        Permission.ReadSms,
        Permission.ReadContacts,
      ]).then((_) {
        getPermission(Permission.ReceiveSms).then((permissionStatus) {
          if (permissionStatus == PermissionStatus.authorized) {
            _initSMSListener();
          }
        });
      });
    });

    // Listeners
    _initScrollListener();
    _initFilterListener();
    _initTabControllerListener();
  }

  @override
  void dispose() {
    _stickyScrollController.dispose();
    _hideButtonController.dispose();
    filterCtrl.dispose();
    tabController.dispose();

    super.dispose();
  }

  Future<Null> _handleRefresh() {
    setState(() {
      _loading = true;
    });
    final Completer<Null> completer = new Completer<Null>();

    new Timer(const Duration(seconds: 3), () {
      _operacionesCUC = new List<Operation>();
      _operacionesCUP = new List<Operation>();
      _resumenOperacionesCUC = new List<ResumeMonth>();
      _resumenOperacionesCUP = new List<ResumeMonth>();

      _reloadSMSOperations();
      new Timer(const Duration(seconds: 5), () {
        if (_loading) {
          setState(() {
            _loading = false;
          });
        }
      });
    });

    return completer.future.then((_) {
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: const Text('Refresh complete'),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKeyCup.currentState.show();
              }
          )
      ));
    });
  }

  requestPermissions(List<Permission> permissionList) async {
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }
    print("Solicitar Permisos + loading...");

    String platformVersion = await SimplePermissions.platformVersion;
    int mayorVersion = int.parse(platformVersion.split(' ')[1].split('.')[0]);
    print(platformVersion);
    print(mayorVersion);
    print(mayorVersion < 6);

    List resultValues = [];
    PermissionStatus resultValue;

    if(mayorVersion < 6) {
      permissionList.forEach((f) {
        resultValues.add({'permission': f, 'permissionStatus':PermissionStatus.authorized});
      });
    }
    else {
      for(int i = 0; i < permissionList.length; i++){
        Permission p = permissionList[i];
        resultValue = await SimplePermissions.requestPermission(p);
        resultValues.add({'permission':p, 'permissionStatus':resultValue});
      }
      print(resultValues);
    }

    if(resultValues.isNotEmpty) {
      if(resultValues.any((p) => p['permission'] == Permission.ReadSms)) {
        if(resultValues
            .firstWhere((rv) => rv['permission'] == Permission.ReadSms)
            ['permissionStatus'] == PermissionStatus.authorized) {
          print("Permitir SMS");
          setState(() {
            _canReadSMS = true;
          });

          await _reloadSMSOperations();
        } else {
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
        if (_loading && resultValues.length == 1) {
          setState(() {
            _loading = false;
          });
        }
      }

      if (resultValues
          .any((p) => p['permission'] == Permission.CallPhone)) {
        if (resultValues
            .firstWhere(
                (rv) => rv['permission'] == Permission.CallPhone)
            ['permissionStatus'] ==
            PermissionStatus.authorized) {
          setState(() {
            _canCall = true;
          });
        } else {
          setState(() {
            _canCall = false;
          });
        }
        if (_loading && resultValues.length == 1) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  void _showSMSModal(SmsMessage msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(msg.address),
            content: new Text(msg.body),
          );
        });
  }

  Future _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _initSMSListener() {
    SmsReceiver receiver = new SmsReceiver();
    receiver.onSmsReceived.listen((SmsMessage msg) {
      if (msg.address == "PAGOxMOVIL") {
        TipoSms smsType = _opListProvider.publicGetTipoSms(msg);

        if (smsType == TipoSms.AUTENTICAR) {
          _showSMSModal(msg);
          prefs.remove('closed_session');
          setState(() {
            _conected = true;
          });
        } else if (smsType == TipoSms.ERROR_AUTENTICACION) {
          _showSMSModal(msg);
          setState(() {
            _conected = false;
          });
        } else {
          if (smsType != TipoSms.ULTIMAS_OPERACIONES) {
            _showSMSModal(msg);
          }

          if (_opListProvider.isOperationsReload(msg)) {
            setState(() {
              _loading = true;
            });

            new Timer(const Duration(seconds: 3), () {
              _operacionesCUC = new List<Operation>();
              _operacionesCUP = new List<Operation>();
              _resumenOperacionesCUC = new List<ResumeMonth>();
              _resumenOperacionesCUP = new List<ResumeMonth>();

              requestPermissions([Permission.ReadSms]);
              new Timer(const Duration(seconds: 5), () {
                if (_loading) {
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

  void _initScrollListener() {
    _stickyScrollController.addListener(() {
      if (_stickyScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if(_isFABButtonVisible){
          setState(() {
            _isFABButtonVisible = false;
          });
        }
      }
      if (_stickyScrollController.position.userScrollDirection == ScrollDirection.forward) {
        if(!_isFABButtonVisible){
          setState(() {
            _isFABButtonVisible = true;
          });
        }
      }
    });

    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.reverse) {
        if(_isFABButtonVisible){
          setState(() {
            _isFABButtonVisible = false;
          });
        }
      }
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
        if(!_isFABButtonVisible){
          setState(() {
            _isFABButtonVisible = true;
          });
        }
      }
    });
  }

  void _initFilterListener() {
    filterCtrl.addListener(() {
      setState(() {
        filter = filterCtrl.text;
      });
    });
  }

  void _initTabControllerListener() {
    tabController = new TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  Future _reloadSMSOperations() async {
    print("Recargar Lista SMS");
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }

    // Cargar la lista de mensajes
//    _opListProvider.ReadSms().then((messages) {
//      _opListProvider.reloadSMSOperations(messages).then(_onReloadSMSOperations);
//    });

    List<SmsMessage> listSMS = await _opListProvider.ReadSms();
    print("Leidos los SMS, antes de recargar las operaciones");

    List<Operation> listOperations =
    await _opListProvider.reloadSMSOperations(listSMS);
    print("Recargadas las operaciones, antes de cargar listas CUP y CUC");
    print("Saldo CUP: " + _opListProvider.saldoCUP.toString());
    print("Saldo CUC: " + _opListProvider.saldoCUC.toString());

    if (_conected == false) {
      if (_opListProvider.isAlreadyConected(listSMS, prefs)) {
        setState(() {
          _conected = true;
        });
      }
    }

    _onReloadSMSOperations(listOperations);
  }

  void _onReloadSMSOperations(List<Operation> operaciones) {
    print("Cargar listas CUP y CUC");
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }

    _operacionesCUP = new List<Operation>();
    _operacionesCUC = new List<Operation>();
    _filteredCUP = new List<Operation>();
    _filteredCUC = new List<Operation>();

//    setState(() {
    _operacionesCUP.addAll(
        operaciones.where((o) => o.moneda == MONEDA.CUP).toList());
    print("OnLoadedCUP_OperationList");
    _resumenOperacionesCUP = _operacionesCUP.isNotEmpty
        ? _opListProvider.getResumenOperaciones(_operacionesCUP)
        : new List<ResumeMonth>();
    print("OnLoadedCUP_resumenOperacionesCUP");

    _operacionesCUC.addAll(
        operaciones.where((o) => o.moneda == MONEDA.CUC).toList());
    print("OnLoadedCUC_OperationList");
    _resumenOperacionesCUC = _operacionesCUC.isNotEmpty
        ? _opListProvider.getResumenOperaciones(_operacionesCUC)
        : new List<ResumeMonth>();
    print("OnLoadedCUC_resumenOperacionesCUC");

    setState(() {
      _filteredCUP.addAll(_operacionesCUP);
      _filteredCUC.addAll(_operacionesCUC);

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Llenar Tabs
    List<Widget> tabsHeader = getTabsHeaders();
    List<Widget> tabsContent = getTabsContents();

    var childButtons = List<UnicornButton>();
    childButtons.add(UnicornButton(
//        hasLabel: true,
//        labelText: _conected ? "Desconectar" : "Conectar",
        currentButton: FloatingActionButton(
          heroTag: "train",
          tooltip: _conected ? "Desconectar" : "Conectar",
          backgroundColor: _conected ? Colors.lightGreen : Colors.blue,
          mini: true,
          child: _conected ? Icon(Icons.close) : Icon(Icons.vpn_key),
          onPressed: _toggleConect,
        )));
    childButtons.add(
        UnicornButton(
        currentButton: FloatingActionButton(
          heroTag: "airplane",
          tooltip: "Consultar Saldo",
          backgroundColor: !_conected ? Colors.grey : Colors.blueAccent,
          mini: true,
          child: Icon(Icons.attach_money),
          onPressed: !_conected ? null : callSaldo,
        )));
    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
          heroTag: "directions",
          tooltip: "Ultimas Operaciones",
          backgroundColor: !_conected ? Colors.grey : Colors.blueAccent,
          mini: true,
          child: Icon(Icons.list),
          onPressed: !_conected ? null : callUltimasOperaciones,
        )));

    return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: new AppBar(
          bottom: !_canReadSMS ? null : new TabBar(
            tabs: tabsHeader, controller: tabController,),
          title: AppBarTitle(
            title: widget.title,
            filterCtrl: filterCtrl,
            isSearch: _isSearch,
            searchOperation: _searchOperation,
          ),
          actions: [
            tabController.index != 0
                ? new IconButton(
              icon: Icon(_isSearch ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            )
                : new Container(),
            MenuAppBar(
              canCall: _canCall,
              requestPermissions: () {
                setState(() => requestPermissions([Permission.CallPhone]));
              },
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
                new Icon(
                  Icons.not_interested,
                  size: 50.0,
                  color: Colors.black54,
                ),
                new Text("Sin Acceso a sus SMS"),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: new Text(
                      "Haga Click Aqui para solicitarlos nuevamente"),
                ),
                FloatingActionButton(
                    onPressed: () {
                      requestPermissions([Permission.ReadSms]);
                    },
                    mini: true,
                    child: new Icon(
                      Icons.refresh,
                    )),
              ],
            ))
            : TabBarView(children: tabsContent, controller: tabController,),
        floatingActionButton: !_canReadSMS || !_isFABButtonVisible
            ? null
            : new UnicornDialer(
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
//            parentButtonBackground: Colors.redAccent,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.add),
            childButtons: childButtons),
      ),
    );
  }

  _toggleConect() {
    if (_conected) {
      //desconectarse
      callDesconectarse(prefs);
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

  List<Widget> getTabsHeaders() {
    List<Widget> tempListHeaders = new List<Widget>();

    // TAB RESUMEN
    tempListHeaders.add(new Tab(
      icon: new Icon(Icons.home),
    ));

    // TAB CUP / CUC
    if (_operacionesCUP.isNotEmpty) {
      tempListHeaders.add(new Tab(
        text: 'CUP',
      ));
    }
    if (_operacionesCUC.isNotEmpty) {
      tempListHeaders.add(new Tab(
        text: 'CUC',
      ));
    }

    return tempListHeaders;
  }

  List<Widget> getTabsContents() {
    List<Widget> tempListContents = new List<Widget>();

    // TAB RESUMEN
    tempListContents.add(HomeDashboard(
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
    if (_operacionesCUP.isNotEmpty) {
      tempListContents.add(
          new RefreshIndicator(
            key: _refreshIndicatorKeyCup,
            onRefresh: _handleRefresh,
            child: new OperationList(
              operaciones: _filteredCUP,
    //        operaciones: _operacionesCUP,
              stickyListController: _stickyScrollController,
            ),
          ));
    }
    if (_operacionesCUC.isNotEmpty) {
      tempListContents.add(
          new RefreshIndicator(
            key: _refreshIndicatorKeyCuc,
            onRefresh: _handleRefresh,
            child: new OperationList(
              operaciones: _filteredCUC,
    //        operaciones: _operacionesCUC,
              stickyListController: _stickyScrollController,
            ),
          ));
    }
    return tempListContents;
  }

  void _toggleSearch() {
    if (_isSearch) {
      filter = '';
      _searchOperation(filter);

      setState(() {
        filterCtrl.text = '';
      });
    }

    setState(() {
      _isSearch = !_isSearch;
    });
  }

  void _searchOperation(String filter) {
    print('Filtering... ' + filter);
    _filteredCUP.clear();
    _filteredCUC.clear();

    if (filter == '') {
      _filteredCUP.addAll(_operacionesCUP);
      _filteredCUC.addAll(_operacionesCUC);
    }
    else {
      setState(() {
        _stickyScrollController.jumpTo(0.0);
        _filteredCUP.addAll(filterOperations(_operacionesCUP));
        _filteredCUC.addAll(filterOperations(_operacionesCUC));
      });
    }
  }

  List<Operation> filterOperations(List<Operation> operaciones) {
    List<Operation> filteredList = new List<Operation>();
    operaciones.forEach((op) {
      if (getOperationTitle(op.tipoOperacion).toLowerCase().contains(
          filter.toLowerCase())
          || new DateFormat('d M yyyy d-M-yyyy d/M/yyyy').format(op.fecha)
              .toString().toLowerCase()
              .contains(filter.toLowerCase())
          || new DateFormat('d MM yyyy d-MM-yyyy d/MM/yyyy').format(op.fecha)
              .toString().toLowerCase()
              .contains(filter.toLowerCase())
          || new DateFormat('M MM MMM MMMM yyyy').format(op.fecha).toString()
              .toLowerCase()
              .contains(filter.toLowerCase())
          || op.importe.toStringAsFixed(2).contains(filter.toLowerCase())
      ) {
        filteredList.add(op);
      }
    });
    return filteredList.toList();
  }
}

class AppBarTitle extends StatelessWidget {
  final bool isSearch;
  final String title;
  final TextEditingController filterCtrl;
  final Function searchOperation;

  const AppBarTitle({
    this.isSearch,
    this.title,
    this.filterCtrl,
    this.searchOperation,
  });

  @override
  Widget build(BuildContext context) {
    return !isSearch
        ? new Text(title)
        : new TextField(
      controller: filterCtrl,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: new InputDecoration(
        prefixIcon: new Icon(Icons.search, color: Colors.white,),
        hintText: "Filtrar...",
        hintStyle: new TextStyle(color: Colors.white,),
      ),
      onChanged: searchOperation,
    );
  }
}
