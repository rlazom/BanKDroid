import 'resumen.dart';
import 'operation.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatelessWidget {
  final Operation lastOperationCUP;
  final Operation lastOperationCUC;
  final List<ResumeMonth> resumeOperationsCUP;
  final List<ResumeMonth> resumeOperationsCUC;

  const HomeDashboard({
    this.lastOperationCUP,
    this.lastOperationCUC,
    this.resumeOperationsCUP,
    this.resumeOperationsCUC,
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> dashboardWidgets = [
      SaldoActual(
        saldo: lastOperationCUP.saldo,
        impLastOp: lastOperationCUP.importe,
        natLastOp: lastOperationCUP.naturaleza,
      ),
      ResumenMensual(
        ingresos: resumeOperationsCUP[0].impCre,
        gastos: resumeOperationsCUP[0].impDeb,
      )
    ];

    resumeOperationsCUP[0].tiposOperaciones.forEach((operationType) {
      dashboardWidgets.add(OperacionGastoIngresoListItem(
        tipoOperacion: operationType.tipoOperacion,
        impCre: operationType.impCre,
        impDeb: operationType.impDeb,
      ));
    });

    return Scrollbar(
      child: ListView(
        children: [
          new Column(
            children: dashboardWidgets,
          )
        ],
      ),
    );
  }
}

class SaldoActual extends StatelessWidget {
  final double saldo;
  final double impLastOp;
  final NaturalezaOperacion natLastOp;

  const SaldoActual({
    this.saldo,
    this.impLastOp,
    this.natLastOp,
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
                "\$" + saldo.toStringAsFixed(2),
                style: TextStyle(fontSize: 30.0),
              ),
              new Icon(
                natLastOp == NaturalezaOperacion.DEBITO
                    ? Icons.arrow_drop_down
                    : Icons.arrow_drop_up,
                size: 12.0,
                color: natLastOp == NaturalezaOperacion.DEBITO
                    ? Colors.redAccent
                    : Colors.lightGreen,
              ),
              new Text(
                impLastOp.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12.0,
                  color: natLastOp == NaturalezaOperacion.DEBITO
                      ? Colors.redAccent
                      : Colors.lightGreen,
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
  final double ingresos;
  final double gastos;

  const ResumenMensual({this.ingresos, this.gastos});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new Card(
        child: new Column(
          children: [
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Expanded(child: new Text("Resumen Mensual: ")),
                  new Text(new DateFormat('MMMM yyyy').format(DateTime.now())),
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
                            ? Colors.redAccent
                            : Colors.lightGreen,
                  ),
                ],
              ),
            ),
            Padding(
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
                        color: Colors.lightGreen,
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
                            ingresos.toStringAsFixed(2) + " CUP",
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
                      new Icon(
                        Icons.arrow_downward,
                        size: 38.0,
                        color: Colors.redAccent,
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(
                            "Gastos",
                            style: TextStyle(
                              fontSize: 11.0,
                            ),
                          ),
                          new Text(
                            gastos.toStringAsFixed(2) + " CUP",
                            style: TextStyle(
                              fontSize: 19.0,
                            ),
                          ),
                        ],
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

class OperacionGastoIngresoListItem extends StatelessWidget {
  final TipoOperacion tipoOperacion;
  final double impDeb;
  final double impCre;

  const OperacionGastoIngresoListItem({
    this.tipoOperacion,
    this.impDeb,
    this.impCre,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: new Card(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: new Column(
                children: [
                  new Row(
                    children: [
                      new Icon(
                        getIconData(tipoOperacion),
                        color: Colors.grey,
                        size: 18.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text(getOperationTitle(tipoOperacion)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  impCre <= 0.0
                      ? new Container()
                      : new Row(
                          children: [
                            new Text(
                              "+" + impCre.toStringAsFixed(2) + " CUP",
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
                              "-" + impDeb.toStringAsFixed(2) + " CUP",
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
