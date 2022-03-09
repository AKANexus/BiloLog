import 'package:bilolog/models/recebimento.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class RecebimentoPacotesProvider with ChangeNotifier {
  List<Pacote> _pacotes = [];
  List<Pacote> get pacotes => [..._pacotes];

  Recebimento? _recebimento;
  Recebimento? get recebimento => _recebimento;

  Pacote? _pacoteDetalhe;
  Pacote? get pacoteDetalhe => _pacoteDetalhe;

  set pacote(Pacote value) {
    _pacoteDetalhe = value;
  }

  set recebimento(Recebimento? value) {
    if (value != null) {
      _recebimento = value;
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
