import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env/apiUrl.dart';
import '../models/coleta.dart';

class NovaColetaProvider with ChangeNotifier {
  Map<String, dynamic>? authInfo;

  late String receivedJson;

  List<EntregaEscaneada> _entregasEscaneadas = [];
  List<EntregaEscaneada> get entregasEscaneadas => [..._entregasEscaneadas];

  List<Coleta> _coletasVerificadas = [];
  List<Coleta> get coletasVerificadas => [..._coletasVerificadas];

  List<Entrega> entregasPorSellerName(String nomeVendedor) {
    return _coletasVerificadas
        .firstWhere((element) => element.nomeVendedor == nomeVendedor)
        .entregas;
  }

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

  List<String> get SellerNames {
    return _coletasVerificadas.map((e) => e.nomeVendedor).toList();
  }

  Future<void> conferirColeta(Function onError) async {
    _coletasVerificadas.clear();
    if (_entregasEscaneadas.length == 0) {
      return;
    }
    if (authInfo == null) return;
    final url = Uri.https(ApiURL.apiAuthority, "/listacoleta/check");
    print(url);
    final jsonBody = {
      'transportadora_uuid': 2345, //authInfo!['uuid'],
      'pacotes': _entregasEscaneadas
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
      final /*List<Map<String, dynamic>>*/ coletasRetornadas =
          json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        receivedJson = response.body;
        for (Map<String, dynamic> coleta in coletasRetornadas) {
          var entregasVerificadas = coleta['pacotes'] as List<dynamic>;
          List<Entrega> entregasAAdicionar = [];
          for (var entregaVerificada in entregasVerificadas) {
            entregasAAdicionar.add(Entrega(
                id: -1,
                vendedorName: coleta['nomeVendedor'],
                cliente: Comprador(
                  id: -1,
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
              id: -1,
              dtColeta: DateTime.now(),
              estadoColeta: ColetaState.EmAnalise,
              nomeVendedor: coleta['nomeVendedor'],
              entregas: entregasAAdicionar));
        }
      } else {
        onError(coletasRetornadas['error']);
      }
    } on SocketException catch (socket) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
    } on TimeoutException catch (timeout) {
      onError("Falha na conexão. Tente novamente mais tarde.");
    } on Exception catch (e) {
      onError(e.toString());
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
