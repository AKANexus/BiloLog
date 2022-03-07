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

  List<PacoteEscaneado> _entregasEscaneadas = [];
  List<PacoteEscaneado> get entregasEscaneadas => [..._entregasEscaneadas];

  List<Coleta> _coletasVerificadas = [];
  List<Coleta> get coletasVerificadas => [..._coletasVerificadas];

  List<Pacote> entregasPorSellerName(String nomeVendedor) {
    return _coletasVerificadas
        .firstWhere((element) => element.nomeVendedor == nomeVendedor)
        .entregas;
  }

  void addNovaEntrega(String seller, int sender) {
    if (!_entregasEscaneadas
        .any((element) => element.senderId == sender && element.id == seller)) {
      _entregasEscaneadas.add(PacoteEscaneado(sender, seller));
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
    return _coletasVerificadas.map((e) => e.nomeVendedor).toSet().toList();
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
      final Map<String, dynamic> coletaRetornada = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        receivedJson = response.body;
        List<Pacote> pacotesAAdicionar = [];
        for (Map<String, dynamic> pacote in coletaRetornada['pacotes']) {
          pacotesAAdicionar.add(Pacote(
              id: -1,
              vendedorName: coletaRetornada['nomeVendedor'],
              cliente: Comprador(
                id: -1,
                nome: pacote['destinatario'],
                endereco: pacote['logradouro'],
                bairro: pacote['bairro'],
                cep: pacote['CEP'],
                complemento: pacote['complemento'] ?? "",
              ),
              codPacote: int.parse(pacote['idPacote']),
              statusEntregas: []));
          _coletasVerificadas.add(Coleta(
              id: -1,
              dtColeta: DateTime.now(),
              estadoColeta: ColetaState.EmAnalise,
              nomeVendedor: coletaRetornada['nomeVendedor'],
              entregas: pacotesAAdicionar));
        }
      } else {
        onError(coletaRetornada['error']);
      }
    } on SocketException catch (socket) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
    } on TimeoutException catch (timeout) {
      onError("Falha na conexão. Tente novamente mais tarde.");
    } catch (e) {
      print(e.toString());
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

class PacoteEscaneado {
  int senderId;
  String id;

  PacoteEscaneado(this.senderId, this.id);
}
