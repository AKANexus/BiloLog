import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/remessaState.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env/apiUrl.dart';

class NovaEntregaProvider with ChangeNotifier {
  Map<String, dynamic>? authInfo;

  late String receivedJson;

  List<PacoteEscaneado> _pacotesEscaneados = [];
  List<PacoteEscaneado> get pacotesEscaneados => [..._pacotesEscaneados];

  List<Entrega> _entregasVerificadas = [];
  List<Entrega> get entregasVerificadas => [..._entregasVerificadas];

  List<Pacote> pacotesPorSellerName(String nomeVendedor) {
    return _entregasVerificadas
        .firstWhere((element) => element.nomeVendedor == nomeVendedor)
        .pacotes;
  }

  void addNovoPacote(String seller, int sender) {
    if (!_pacotesEscaneados
        .any((element) => element.senderId == sender && element.id == seller)) {
      _pacotesEscaneados.add(PacoteEscaneado(sender, seller, ""));
    }
  }

  void startNewEntrega() {
    print("Nova entrega iniciada");
    _pacotesEscaneados.clear();
  }

  List<int> get senders {
    List<int> _senders = [];
    for (var entEsc in _pacotesEscaneados) {
      if (!_senders.contains(entEsc.senderId)) {
        _senders.add(entEsc.senderId);
      }
    }
    return _senders;
  }

  List<String> pacotesBySender(String sender) {
    return _pacotesEscaneados
        .where((element) => element.senderId == sender)
        .map((e) => e.id)
        .toList();
  }

  List<String> get SellerNames {
    return _entregasVerificadas.map((e) => e.nomeVendedor).toSet().toList();
  }

  Future<void> conferirEntrega(Function onError) async {
    _entregasVerificadas.clear();
    if (_pacotesEscaneados.length == 0) {
      return;
    }
    if (authInfo == null) return;
    final url = Uri.https(ApiURL.apiAuthority, "/entregas/check");
    print(url);
    final jsonBody = {
      'transportadora_uuid': 2345, //authInfo!['uuid'],
      'pacotes': _pacotesEscaneados
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
      final Map<String, dynamic> entregaRetornada = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        receivedJson = response.body;
        List<Pacote> pacotesAAdicionar = [];
        for (Map<String, dynamic> pacote in entregaRetornada['pacotes']) {
          if (pacote['error'] != null) {
            pacotesAAdicionar.add(Pacote(
                errorMessage: pacote['error'],
                id: -1,
                vendedorName: "",
                cliente: Comprador(
                  id: -1,
                  nome: "",
                  endereco: "",
                  bairro: "",
                  cep: "",
                  complemento: "",
                ),
                codPacote: -1,
                statusPacotes: []));
          } else {
            pacotesAAdicionar.add(Pacote(
                id: -1,
                vendedorName: "",
                cliente: Comprador(
                  id: -1,
                  nome: pacote['destinatario'],
                  endereco: pacote['logradouro'],
                  bairro: pacote['bairro'],
                  cep: pacote['CEP'],
                  complemento: pacote['complemento'] ?? "",
                ),
                codPacote: pacote['id'],
                statusPacotes: []));
          }
          _entregasVerificadas.add(Entrega(
              id: -1,
              dtColeta: DateTime.now(),
              estadoColeta: RemessaState.EmAnalise,
              nomeVendedor: "",
              pacotes: pacotesAAdicionar));
        }
      } else {
        onError(entregaRetornada['error']);
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
  String tamanho;

  PacoteEscaneado(this.senderId, this.id, this.tamanho);
}
