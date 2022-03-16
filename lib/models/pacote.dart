import 'package:bilolog/models/status_pacote.dart';

import 'cliente.dart';

class Pacote {
  final String id;
  final String codPacote;
  final Comprador cliente;
  final List<StatusPacote> statusPacotes;
  final String vendedorName;
  String? mlUserID;
  String? errorMessage;

  Pacote(
      {required this.id,
      required this.codPacote,
      required this.cliente,
      required this.statusPacotes,
      required this.vendedorName,
      this.mlUserID,
      this.errorMessage});

  bool get hasError => errorMessage != null;

  String get ultimoStatus {
    if (statusPacotes.isEmpty) return "";
    return statusPacotes.first.descricaoStatus[0].toUpperCase() +
        statusPacotes.first.descricaoStatus.substring(1).toLowerCase();
  }
}
