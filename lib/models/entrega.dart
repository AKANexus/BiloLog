import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/statusEntrega.dart';

import 'cliente.dart';

class Pacote {
  final int id;
  final int codPacote;
  // final ColetaState statusEntrega;
  // final String numColeta;
  final Comprador cliente;
  final List<StatusEntrega> statusEntregas;
  final String vendedorName;

  Pacote({
    required this.id,
    required this.codPacote,
    // required this.statusEntrega,
    // required this.numColeta,
    required this.cliente,
    required this.statusEntregas,
    required this.vendedorName,
  });

  String get ultimoStatus {
    if (statusEntregas.length < 1) return "Coletando...";
    return statusEntregas.last.descricaoStatus;
  }
}
