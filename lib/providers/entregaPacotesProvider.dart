import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class EntregaPacotesProvider with ChangeNotifier {
  void notify() {
    notifyListeners();
  }

  List<Pacote> _pacotes = [];
  List<Pacote> get pacotes => [..._pacotes];

  Entrega? _entrega;
  Entrega? get entrega => _entrega;

  Pacote? _pacoteDetalhe;
  Pacote? get pacoteDetalhe => _pacoteDetalhe;

  set pacote(Pacote value) {
    _pacoteDetalhe = value;
  }

  set entrega(Entrega? value) {
    if (value != null) {
      _entrega = value;
      _pacotes.clear();
      for (var pacote in value.pacotes) {
        _pacotes.add(pacote);
      }
    }
  }

  set pacotes(List<Pacote> value) {
    _pacotes.clear();
    for (var pacote in value) {
      _pacotes.add(pacote);
    }
  }
}
