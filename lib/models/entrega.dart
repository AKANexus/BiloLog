import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/statusEntrega.dart';

import 'cliente.dart';

class Entrega {
  final int id;
  final int codPacote;
  // final ColetaState statusEntrega;
  // final String numColeta;
  final Vendedor cliente;
  final List<StatusEntrega> statusEntregas;

  Entrega({
    required this.id,
    required this.codPacote,
    // required this.statusEntrega,
    // required this.numColeta,
    required this.cliente,
    required this.statusEntregas,
  });
}
