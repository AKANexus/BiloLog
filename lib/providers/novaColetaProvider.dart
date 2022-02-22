import 'dart:convert';
import 'dart:math';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/coleta.dart';

class NovaColetaProvider with ChangeNotifier {
  Map<String, dynamic>? authInfo;

  List<EntregaEscaneada> _entregasEscaneadas = [];
  List<EntregaEscaneada> get entregasEscaneadas => [..._entregasEscaneadas];

  List<Coleta> _coletasVerificadas = [];
  List<Coleta> get coletasVerificadas => [..._coletasVerificadas];

  void addNovaEntrega(String seller, int sender) {
    if (!_entregasEscaneadas
        .any((element) => element.senderId == sender && element.id == seller)) {
      _entregasEscaneadas.add(EntregaEscaneada(sender, seller));
    }
  }

  void startNewColeta() {
    print("Nova coleta iniciada");
    _entregasEscaneadas.clear();
  }

  List<int> get senders {
    List<int> _senders = [];
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
    final url = Uri.https("bilolog.herokuapp.com", "/listacoleta/check");
    final jsonBody = {
      'transportadora_uuid': 2345, //authInfo!['uuid'],
      'listacoleta': _entregasEscaneadas
          .map((e) => {'id': e.id, 'sender_id': e.senderId})
          .toList(),
    };

    try {
      final response = await http
          .post(url,
              headers: {
                'apiKey': authInfo!['apiKey'] as String,
                'content-type': 'application/json'
              },
              body: json.encode(jsonBody))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final /*List<Map<String, dynamic>>*/ coletasRetornadas =
            json.decode(response.body);
        for (Map<String, dynamic> coleta in coletasRetornadas) {
          var entregasVerificadas = coleta['listaColeta'] as List<dynamic>;
          List<Entrega> entregasAAdicionar = [];
          for (var entregaVerificada in entregasVerificadas) {
            entregasAAdicionar.add(Entrega(
                id: -1,
                cliente: Comprador(
                  id: "",
                  nome: entregaVerificada['destinatario'],
                  endereco: entregaVerificada['logradouro'],
                  bairro: entregaVerificada['bairro'],
                  cep: entregaVerificada['CEP'],
                  complemento: entregaVerificada['complemento'] ?? "",
                ),
                codPacote: int.parse(entregaVerificada['idPacote']),
                statusEntregas: []));
          }
          _coletasVerificadas.add(Coleta(
              id: "-1",
              dtColeta: DateTime.now(),
              estadoColeta: ColetaState.EmAnalise,
              nomeVendedor: coleta['nickanme'],
              entregas: entregasAAdicionar));
        }
        //notifyListeners();
      }
    } catch (e) {
      print('falha em novaColetaProvider:');
      print(e);
    }
  }
  //\listacoletas
  //Post
  //header: apiKey
  //body:
  //vendedor_uuid: _uuid
  //array[{id, senderId}]
}

class EntregaEscaneada {
  int senderId;
  String id;

  EntregaEscaneada(this.senderId, this.id);
}
