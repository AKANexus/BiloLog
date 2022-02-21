import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/coleta.dart';

class NovaColetaProvider with ChangeNotifier {
  Map<String, dynamic>? authInfo;

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

  Future<void> conferirColeta() async {
    if (_entregasEscaneadas.length == 0) {
      return;
    }
    if (authInfo == null) return;
    final url = Uri.https("bilolog.kerokuapp.com", "/listacoleta");
    try {
      final response = http.post(url, headers: {
        'apiKey': authInfo!['apiKey']
      }, body: {
        'vendedor_uuid': authInfo!['uuid'],
        'listacoleta': _entregasEscaneadas
            .map((e) => {'entregaId': e.id, 'senderId': e.senderId})
      }).timeout(Duration(seconds: 10));
      print("sent");
    } catch (e) {}
  }
  //\listacoletas
  //Post
  //header: apiKey
  //body:
  //vendedor_uuid: _uuid
  //array[{id, senderId}]
}

class EntregaEscaneada {
  String senderId;
  String id;

  EntregaEscaneada(this.senderId, this.id);
}
