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
  int? mlUserID;
  String? errorMessage;

  Pacote(
      {required this.id,
      required this.codPacote,
      // required this.statusEntrega,
      // required this.numColeta,
      required this.cliente,
      required this.statusPacotes,
      required this.vendedorName,
      this.mlUserID});

  bool get hasError => errorMessage != null;

  String get ultimoStatus {
    if (statusPacotes.length < 1) return "";
    return statusPacotes.last.descricaoStatus;
  }
}
