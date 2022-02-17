import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/statusEntrega.dart';

import 'cliente.dart';

class Entrega {
  int id;
  String codPacote;
  ColetaState statusEntrega;
  String numColeta;
  Cliente cliente;
  List<StatusEntrega> statusEntrega;
}
