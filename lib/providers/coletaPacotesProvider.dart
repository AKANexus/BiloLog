import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class ColetaPacotesProvider with ChangeNotifier {
  List<Pacote> _pacotes = [];
  List<Pacote> get pacotes => [..._pacotes];

  Coleta? _coleta;
  Coleta? get coleta => _coleta;

  Pacote? _pacoteDetalhe;
  Pacote? get pacoteDetalhe => _pacoteDetalhe;

  set pacote(Pacote value) {
    _pacoteDetalhe = value;
  }

  set coleta(Coleta? value) {
    if (value != null) {
      _coleta = value;
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
