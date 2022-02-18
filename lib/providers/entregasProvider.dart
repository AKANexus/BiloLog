import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

class EntregasProvider with ChangeNotifier {
  List<Entrega> _entregas = [];
  List<Entrega> get entregas => [..._entregas];

  Coleta? _coleta;
  Coleta? get coleta => _coleta;

  Entrega? _entregaDetalhe;
  Entrega? get entregaDetalhe => _entregaDetalhe;

  set entrega(Entrega value) {
    _entregaDetalhe = value;
  }

  set coleta(Coleta? value) {
    if (value != null) {
      _coleta = value;
      _entregas.clear();
      for (var entrega in value.entregas) {
        _entregas.add(entrega);
      }
    }
  }

  set entregas(List<Entrega> value) {
    _entregas.clear();
    for (var entrega in value) {
      _entregas.add(entrega);
    }
  }
}
