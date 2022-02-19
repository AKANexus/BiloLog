import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

import '../models/coleta.dart';

class NovaColetaProvider with ChangeNotifier {
  List<EntregaEscaneada> _entregasEscaneadas = [];
  List<EntregaEscaneada> get entregasEscaneadas => [..._entregasEscaneadas];

  void addNovaEntrega(String seller, String sender) {
    if (!_entregasEscaneadas
        .any((element) => element.senderId == sender && element.id == seller)) {
      _entregasEscaneadas.add(EntregaEscaneada(sender, seller));
    }
  }

  void startNewColeta() {
    print("Nova coleta iniciada");
    _entregasEscaneadas.clear();
  }

  List<String> get senders {
    List<String> _senders = [];
    for (var entEsc in _entregasEscaneadas) {
      if (!_senders.contains(entEsc.senderId)) {
        _senders.add(entEsc.senderId);
      }
    }
    return _senders;
  }

  List<String> entregasBySender(String sender) {
    return _entregasEscaneadas
        .where((element) => element.senderId == sender)
        .map((e) => e.id)
        .toList();
  }
}

class EntregaEscaneada {
  String senderId;
  String id;

  EntregaEscaneada(this.senderId, this.id);
}
