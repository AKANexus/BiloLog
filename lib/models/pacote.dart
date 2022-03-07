import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/statusEntrega.dart';

import 'cliente.dart';

class Pacote {
  final int id;
  final int codPacote;
  // final ColetaState statusEntrega;
  // final String numColeta;
  final Comprador cliente;
  final List<StatusPacote> statusPacotes;
  final String vendedorName;

  Pacote({
    required this.id,
    required this.codPacote,
    // required this.statusEntrega,
    // required this.numColeta,
    required this.cliente,
    required this.statusPacotes,
    required this.vendedorName,
  });

  String get ultimoStatus {
    if (statusPacotes.length < 1) return "Coletando...";
    return statusPacotes.last.descricaoStatus;
  }
}
