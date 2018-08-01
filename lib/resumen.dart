import 'operation.dart';

class ResumeTypeOperation{
  TipoOperacion tipoOperacion;
  double impCre;
  double impDeb;

  ResumeTypeOperation(TipoOperacion pTipoOperacion,double pImpCre,double pImpDeb){
    this.tipoOperacion = pTipoOperacion;
    this.impCre = pImpCre;
    this.impDeb = pImpDeb;
  }
}

class ResumeMonth{
  int year;
  int month;
  double impCre;
  double impDeb;
  List<ResumeTypeOperation> tiposOperaciones;

  ResumeMonth(int pYear, int pMonth, double pImpCre ,double pImpDeb, List<ResumeTypeOperation> pTiposOps){
    this.year = pYear;
    this.month = pMonth;
    this.impCre = pImpCre;
    this.impDeb = pImpDeb;
    this.tiposOperaciones = pTiposOps;
  }
}