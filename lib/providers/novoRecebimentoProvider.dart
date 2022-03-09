import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/remessaState.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env/apiUrl.dart';
import '../models/coleta.dart';

class NovoRecebimentoProvider with ChangeNotifier {
  Map<String, dynamic>? authInfo;

  late String receivedJson;

  List<PacoteEscaneado> _pacotesEscaneados = [];
  List<PacoteEscaneado> get pacotesEscaneados => [..._pacotesEscaneados];

  List<Coleta> _coletasVerificadas = [];
  List<Coleta> get coletasVerificadas => [..._coletasVerificadas];

  List<Pacote> pacotesPorSellerName(String nomeVendedor) {
    return _coletasVerificadas
        .firstWhere((element) => element.nomeVendedor == nomeVendedor)
        .pacotes;
  }

  void addNovoPacote(String seller, int sender, String tamanho) {
    if (!_pacotesEscaneados
        .any((element) => element.senderId == sender && element.id == seller)) {
      _pacotesEscaneados.add(PacoteEscaneado(sender, seller, tamanho));
    }
  }

  void startNewColeta() {
    print("Nova coleta iniciada");
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
    return _coletasVerificadas.map((e) => e.nomeVendedor).toSet().toList();
  }

  Future<void> conferirColeta(Function onError) async {
    _coletasVerificadas.clear();
    if (_pacotesEscaneados.length == 0) {
      return;
    }
    if (authInfo == null) return;
    final url = Uri.https(ApiURL.apiAuthority, "/listacoleta/check");
    print(url);
    final jsonBody = {
      'transportadora_uuid': 2345, //authInfo!['uuid'],
      'pacotes': _pacotesEscaneados
          .map((e) => {'id': e.id, 'sender_id': e.senderId, 'size': e.tamanho})
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
              statusPacotes: []));
          _coletasVerificadas.add(Coleta(
              id: -1,
              dtColeta: DateTime.now(),
              estadoColeta: RemessaState.EmAnalise,
              nomeVendedor: coletaRetornada['nomeVendedor'],
              pacotes: pacotesAAdicionar));
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
  String tamanho;

  PacoteEscaneado(this.senderId, this.id, this.tamanho);
}
