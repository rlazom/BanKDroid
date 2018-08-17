import 'operation.dart';

class ResumeTypeOperation{
  TipoOperacion tipoOperacion;
  double impCre;
  double impDeb;
  List<Operation> operations;

  ResumeTypeOperation(TipoOperacion pTipoOperacion, double pImpCre, double pImpDeb, List<Operation> pOperations){
    this.tipoOperacion = pTipoOperacion;
    this.impCre = pImpCre;
    this.impDeb = pImpDeb;
    this.operations = pOperations;
  }
}

class ResumeMonth{
  DateTime fecha;
  double impCre;
  double impDeb;
  List<ResumeTypeOperation> tiposOperaciones;

  ResumeMonth(DateTime pfecha, double pimpCre ,double pimpDeb, List<ResumeTypeOperation> ptiposOperaciones){
    this.fecha = pfecha;
    this.impCre = pimpCre;
    this.impDeb = pimpDeb;
    this.tiposOperaciones = ptiposOperaciones;
  }
}