import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';

class Coleta {
  final int id;
  final DateTime dtColeta;
  final String nomeVendedor;
  final int pacotesColetados;
  final ColetaState estadoColeta;
  final List<Entrega> entregas;

  Coleta({
    required this.id,
    required this.dtColeta,
    required this.nomeVendedor,
    required this.pacotesColetados,
    required this.estadoColeta,
    required this.entregas,
  });
}
