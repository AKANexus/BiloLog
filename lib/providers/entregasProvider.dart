import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

class EntregasProvider with ChangeNotifier {
  List<Entrega> _entregas = [];

  List<Entrega> get entregas => [..._entregas];

  set entregas(List<Entrega> value) {
    _entregas.clear();
    for (var entrega in value) {
      _entregas.add(entrega);
    }
  }
}
