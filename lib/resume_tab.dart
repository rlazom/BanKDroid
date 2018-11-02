import 'ussd_methods.dart';
import 'resumen.dart';
import 'operation.dart';
import 'operation_list_item_modal.dart';
import 'operation_list_type_modal.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatefulWidget {
  final bool conected;
  final double saldoCUP;
  final double saldoCUC;
  final Operation lastOperationCUP;
  final Operation lastOperationCUC;
  final List<ResumeMonth> resumeOperationsCUP;
  final List<ResumeMonth> resumeOperationsCUC;
  final ScrollController hideButtonController;

  const HomeDashboard({
    this.conected,
    this.saldoCUP,
    this.saldoCUC,
    this.lastOperationCUP,
    this.lastOperationCUC,
    this.resumeOperationsCUP,
    this.resumeOperationsCUC,
    this.hideButtonController,
  });

  @override
  _HomeDashboardState createState() => new _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  bool isCurrencyCUP = true;

  @override
  Widget build(BuildContext context) {
    List<Widget> dashboardWidgets = new List<Widget>();
    int cantLists = (widget.saldoCUP != null ? 1 : 0) + (widget.saldoCUC != null ? 1 : 0);

    if (widget.lastOperationCUP != null || widget.lastOperationCUC != null || cantLists != 0) {
      dashboardWidgets.addAll(generateDashBoardWidgets(cantLists));
    } else {
      dashboardWidgets.addAll(generateListNoSMSData());

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dashboardWidgets,
        ),
      );
    }

    return Scrollbar(
      child: ListView(
        controller: widget.hideButtonController,
        children: [
          new Column(
            children: dashboardWidgets,
          )
        ],
      ),
    );
  }

  void onToggleCurrency() {
    if ((this.isCurrencyCUP && widget.saldoCUC != null) ||
        (!this.isCurrencyCUP && widget.saldoCUP != null)) {
      setState(() {
        this.isCurrencyCUP = !this.isCurrencyCUP;
      });
    }
  }

  List<Widget> generateDashBoardWidgets(int cantLists){
    List<Widget> dashboardWidgets = new List<Widget>();

    dashboardWidgets.add(
        SaldoActual(
          saldo: isCurrencyCUP ? widget.saldoCUP : widget.saldoCUC,
          lastOp: isCurrencyCUP
              ? widget.lastOperationCUP != null
              ? widget.lastOperationCUP
              : null
              : widget.lastOperationCUC != null
              ? widget.lastOperationCUC
              : null,
          moneda: isCurrencyCUP ? MONEDA.CUP : MONEDA.CUC,
          cantLists: cantLists,
          onToggleCurrency: onToggleCurrency,
        ));

    List<ResumeMonth> resume = isCurrencyCUP
        ? widget.resumeOperationsCUP
        : widget.resumeOperationsCUC;

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
  List<Widget> generateListNoSMSData(){
    return [
      new Icon(
        Icons.speaker_notes_off,
        size: 50.0,
        color: Colors.black54,
      ),
      new Text("Sin Datos en sus SMS"),
      new Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: new Text(widget.conected
            ? "Click Aqui "
            : "Conéctese " + "para solicitar Ultimas Operaciones"),
      ),
      new FloatingActionButton(
          onPressed: widget.conected ? callUltimasOperaciones : null,
          backgroundColor: widget.conected ? Colors.blue : Colors.grey,
          mini: true,
          child: new Icon(
            Icons.refresh,
          )),
    ];
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
                onPressed: () => showOperationModal(context, lastOp),
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
    return FlatButton(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      onPressed: () => showOperationsTypeModal(context,operations),
      child: new Card(
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
