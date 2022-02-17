import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';

class Coleta {
  int id;
  DateTime dtColeta;
  String nomeCliente;
  int pacotesColetados;
  ColetaState estadoColeta;
  List<Entrega> entregas;
}
