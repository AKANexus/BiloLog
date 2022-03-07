import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

class ColetaPacotesProvider with ChangeNotifier {
  List<Pacote> _entregas = [];
  List<Pacote> get entregas => [..._entregas];

  Coleta? _coleta;
  Coleta? get coleta => _coleta;

  Pacote? _entregaDetalhe;
  Pacote? get entregaDetalhe => _entregaDetalhe;

  set entrega(Pacote value) {
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

  set entregas(List<Pacote> value) {
    _entregas.clear();
    for (var entrega in value) {
      _entregas.add(entrega);
    }
  }
}
