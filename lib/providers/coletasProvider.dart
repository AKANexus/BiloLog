import 'package:bilolog/models/coleta.dart';
import 'package:flutter/material.dart';

class ColetasProvider with ChangeNotifier {
  List<Coleta> _coletas = [];

  List<Coleta> get coletas => [..._coletas];
  List<Coleta> get coletasTeste => [Coleta(), Coleta(), Coleta()];
}
