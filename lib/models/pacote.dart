import 'package:bilolog/models/statusRemessa.dart';
import 'package:bilolog/models/statusPacote.dart';

import 'cliente.dart';

class Pacote {
  final int id;
  final int codPacote;
  final Comprador cliente;
  final List<StatusPacote> statusPacotes;
  final String vendedorName;
  int? mlUserID;
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
    if (statusPacotes.length < 1) return "";
    return statusPacotes.last.descricaoStatus;
  }
}
