import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/statusEntrega.dart';

import 'cliente.dart';

class Entrega {
  final int id;
  final int codPacote;
  // final ColetaState statusEntrega;
  // final String numColeta;
  final Comprador cliente;
  final List<StatusEntrega> statusEntregas;

  Entrega({
    required this.id,
    required this.codPacote,
    // required this.statusEntrega,
    // required this.numColeta,
    required this.cliente,
    required this.statusEntregas,
  });

  String get ultimoStatus {
    if (statusEntregas.length < 1) return "Não disponível";
    return statusEntregas.last.descricaoStatus;
  }
}
