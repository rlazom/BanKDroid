import 'package:bankdroid/common/enums.dart';
import 'package:bankdroid/common/l10n/applocalizations.dart';
import 'package:bankdroid/common/notifiers/operation_list.dart';
import 'package:bankdroid/common/notifiers/view_model_consumer.dart';
import 'package:bankdroid/common/theme/colors.dart';
import 'package:bankdroid/common/widgets/operation_modal_item.dart';
import 'package:bankdroid/models/operation.dart';
import 'package:bankdroid/models/resumen.dart';
import 'package:bankdroid/module/home/components/resume_tab/view_model/resume_tab_view_model.dart';
import 'package:bankdroid/views/operation_list_item_modal.dart';
import 'package:bankdroid/views/operation_list_type_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//import '../../../../views/operation_list_item_modal.dart';
//import '../../../../views/operation_list_type_modal.dart';
//import '../../../../models/resumen.dart';
//import '../../../../models/operation.dart';
//import '../../../../utils/ussd_methods.dart';
//import '../../../../common/theme/colors.dart';
//import '../../../../common/enums.dart';

class ResumeTab extends StatelessWidget with ViewModelConsumer<ResumeTabViewModel> {
  final GlobalKey<ScaffoldState> _resumeTabScaffoldKey = new GlobalKey<ScaffoldState>();
//  final bool conected;
//  final double saldoCUP;
//  final double saldoCUC;
//  final Operation lastOperationCUP;
//  final Operation lastOperationCUC;
//  final List<ResumeMonth> resumeOperationsCUP;
//  final List<ResumeMonth> resumeOperationsCUC;

//  ResumeTab({Key key, this.conected, this.saldoCUP, this.saldoCUC, this.lastOperationCUP, this.lastOperationCUC, this.resumeOperationsCUP, this.resumeOperationsCUC}) : super(key: key);
  ResumeTab({Key key}) : super(key: key);

  ResumeTabViewModel _createViewModel(BuildContext context) {
    return ResumeTabViewModel(resumeTabScaffoldKey: _resumeTabScaffoldKey);
  }

  void _scheduleLoadService(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await viewModel(context).loadData(context);
    });
  }

  _buildDashboard(BuildContext context) {
    List<Widget> dashboardWidgets = new List<Widget>();
    int cantLists = (viewModel(context).balanceCUP != null ? 1 : 0) + (viewModel(context).balanceCUC != null ? 1 : 0);

    if (viewModel(context).lastOperationCUP != null || viewModel(context).lastOperationCUC != null || cantLists != 0) {
      dashboardWidgets.addAll(generateDashBoardWidgets(context, cantLists));
    } else {
      dashboardWidgets.addAll(generateListNoSMSData());
    }
    return dashboardWidgets;
  }

  List<Widget> generateListNoSMSData() {
    return [
      new Icon(
        Icons.speaker_notes_off,
        size: 50.0,
        color: Colors.black54,
      ),
      new Text("Sin Datos en sus SMS"),
      new Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
//        child: new Text(conected ? "Click Aqui " : "Conéctese " + "para solicitar Ultimas Operaciones"),
        child: new Text(true ? "Click Aqui " : "Conéctese " + "para solicitar Ultimas Operaciones"),
      ),
      new FloatingActionButton(
//          onPressed: conected ? callUltimasOperaciones : null,
          onPressed: true ? (){} : null,
          backgroundColor: true ? Colors.blue : Colors.grey,
          mini: true,
          child: new Icon(
            Icons.refresh,
          )),
    ];
  }

  List<Widget> generateDashBoardWidgets(BuildContext context, int cantLists) {
    List<Widget> dashboardWidgets = new List<Widget>();

    bool isCurrencyCUP = viewModel(context).isCurrencyCUP;
    dashboardWidgets.add(
        SaldoActual(
          saldo: isCurrencyCUP ? viewModel(context).balanceCUP : viewModel(context).balanceCUC,
          lastOp: isCurrencyCUP
              ? viewModel(context).lastOperationCUP != null
              ? viewModel(context).lastOperationCUP
              : null
              : viewModel(context).lastOperationCUC != null
              ? viewModel(context).lastOperationCUC
              : null,
          moneda: isCurrencyCUP ? MONEDA.CUP : MONEDA.CUC,
          cantLists: cantLists,
          onToggleCurrency: viewModel(context).toggleCurrency,
        ));

    List<ResumeMonth> resume = isCurrencyCUP
        ? viewModel(context).resumeOperationsCUP
        : viewModel(context).resumeOperationsCUC;

    if(resume.isNotEmpty) {
      resume.forEach((resumenMensual) {
        dashboardWidgets.add(ResumenMensual(
          fecha: resumenMensual.fecha,
          ingresos: resumenMensual.impCre,
          gastos: resumenMensual.impDeb,
          tiposOperaciones: resumenMensual.tiposOperaciones,
          moneda: isCurrencyCUP ? MONEDA.CUP : MONEDA.CUC,
        ));
      });
    }
    return dashboardWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _resumeTabScaffoldKey,
      body: ChangeNotifierProvider(
        create: _createViewModel,
        child: Consumer<ResumeTabViewModel>(
          builder: (context, viewModel, child) {
            var localization = Localization.of(context);

            if(viewModel.normal) {
              _scheduleLoadService(context);
              return Center(child: CircularProgressIndicator());
            }
            if(viewModel.loading) {
              return Center(child: CircularProgressIndicator());
            }
            return new Scrollbar(
              child: ListView(
                children: [
                  new Column(
                    children: _buildDashboard(context),
                  )
                ],
              ),
            );
//            return new Consumer<OperationList>(
//              builder: (context, opViewModel, child) {
//
//                return new Scrollbar(
//                  child: ListView(
//                    children: [
//                      new Column(
//                        children: _buildDashboard(viewModel),
//                      )
//                    ],
//                  ),
//                );
//              },
//            );
          },
        ),
      ),
    );
  }
}

class SaldoActual extends StatelessWidget {
  final double saldo;
  final MONEDA moneda;
  final Function onToggleCurrency;
  final int cantLists;
  final Operation lastOp;

  const SaldoActual({
    this.saldo,
    this.moneda,
    this.onToggleCurrency,
    this.cantLists,
    this.lastOp,
  });

  _showOperationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(16.0),
        children: [
          OperationModalItem(operation: lastOp,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
      child: new Column(
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text(
                "Saldo Actual",
                style: TextStyle(fontSize: 11.0),
              ),
            ],
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text(
                '\$ ' + saldo.toStringAsFixed(2),
                style: TextStyle(fontSize: 30.0),
              ),
              new FlatButton(
//                onPressed: () => showOperationModal(context, lastOp),
                onPressed: () => _showOperationDetails(context),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Text(
                      getMonedaStr(moneda),
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black54,
                      ),
                    ),
                    Row(
                      children: [
                        new Icon(
                          lastOp == null
                              ? null
                              : lastOp.naturaleza == NaturalezaOperacion.DEBITO
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                          size: 12.0,
                          color: lastOp == null ? null : getIconColor(lastOp.naturaleza),
                        ),
                        new Text(
                          lastOp == null ? '' : lastOp.importe.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: lastOp == null ? null : lastOp.naturaleza == NaturalezaOperacion.DEBITO
                                ? kColorDebito
                                : kColorCredito,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: FloatingActionButton(
                  elevation: cantLists == 2 ? 1.0 : 0.0,
                  tooltip: cantLists != 2 ? "" : "Cambiar Moneda",
                  child: new Icon(Icons.repeat),
                  backgroundColor: cantLists == 2 ? Colors.blue : Colors.grey,
                  mini: true,
                  onPressed: cantLists == 2 ? onToggleCurrency : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResumenMensual extends StatelessWidget {
  final DateTime fecha;
  final double ingresos;
  final double gastos;
  final List<ResumeTypeOperation> tiposOperaciones;
  final MONEDA moneda;

  const ResumenMensual({
    this.fecha,
    this.ingresos,
    this.gastos,
    this.tiposOperaciones,
    this.moneda,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> resumeList = new List<Widget>();

    resumeList.add(generateResumeCard());
    resumeList.addAll(generateResumeListTiposOperations());
    resumeList.add(
      new Divider(
        height: 10.0,
      ),
    );

    return new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new Column(
        children: resumeList,
      ),
    );
  }

  Card generateResumeCard() {
    return new Card(
      child: new Column(
        children: [
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Expanded(
                    child: new Text(new DateFormat('MMMM yyyy').format(fecha),
                        style: TextStyle(color: Colors.black54))),
                new Text((ingresos - gastos).abs().toStringAsFixed(2),
                    style: TextStyle(color: Colors.black54, fontSize: 11.0)),
                new Icon(
                  ingresos - gastos == 0
                      ? Icons.trending_flat
                      : ingresos - gastos < 0
                      ? Icons.trending_down
                      : Icons.trending_up,
                  size: 20.0,
                  color: ingresos - gastos == 0
                      ? Colors.black54
                      : ingresos - gastos < 0
                      ? kColorDebito
                      : kColorCredito,
                ),
              ],
            ),
          ),
          new Padding(
            padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Row(
                  children: [
                    new Icon(
                      Icons.arrow_upward,
                      size: 38.0,
                      color: kColorCredito,
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          "Ingresos",
                          style: TextStyle(
                            fontSize: 11.0,
                          ),
                        ),
                        new Text(
                          ingresos.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 19.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                new Row(
                  children: [
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        new Text(
                          "Gastos",
                          style: TextStyle(
                            fontSize: 11.0,
                          ),
                        ),
                        new Text(
                          gastos.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 19.0,
                          ),
                        ),
                      ],
                    ),
                    new Icon(
                      Icons.arrow_downward,
                      size: 38.0,
                      color: kColorDebito,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> generateResumeListTiposOperations() {
    List<Widget> list = new List<Widget>();

    tiposOperaciones.forEach((operationType) {
      list.add(OperacionGastoIngresoListItem(
        tipoOperacion: operationType.tipoOperacion,
        impCre: operationType.impCre,
        impDeb: operationType.impDeb,
        moneda: moneda,
        operations: operationType.operations,
      ));
    });

    return list;
  }
}

class OperacionGastoIngresoListItem extends StatelessWidget {
  final TipoOperacion tipoOperacion;
  final double impDeb;
  final double impCre;
  final MONEDA moneda;
  final List<Operation> operations;

  const OperacionGastoIngresoListItem({
    this.tipoOperacion,
    this.impDeb,
    this.impCre,
    this.moneda,
    this.operations,
  });

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        onTap: () => showOperationsTypeModal(context, operations),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: new Row(
                children: [
                  new Icon(
                    getIconData(tipoOperacion),
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: new Text(getOperationTitle(tipoOperacion)),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  impCre <= 0.0
                      ? new Container()
                      : new Row(
                          children: [
                            new Text(
                              "+" + impCre.toStringAsFixed(2) + " " + getMonedaStr(moneda),
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.lightGreen),
                            ),
                          ],
                        ),
                  impDeb <= 0.0
                      ? new Container()
                      : new Row(
                          children: [
                            new Text(
                              "-" + impDeb.toStringAsFixed(2) + " " + getMonedaStr(moneda),
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.redAccent),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
