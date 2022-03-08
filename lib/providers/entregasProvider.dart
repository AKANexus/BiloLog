import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/statusEntrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../env/apiUrl.dart';

class EntregasProvider with ChangeNotifier {
  set apiKey(String value) {
    _apiKey = value;
  }

  String? _apiKey;

  List<Entrega> _entregas = [];
  List<Entrega> get entregas => [..._entregas];

  Future<void> getEntregas(
      Function onError, DateTime startDate, DateTime endDate) async {
    _entregas.clear();
    final url = Uri(
        scheme: 'https',
        host: ApiURL.apiAuthority,
        path: '/entregas/',
        query:
            'dateStart=${DateTime(startDate.year, startDate.month, startDate.day).toIso8601String()}&dateEnd=${DateTime(endDate.year, endDate.month, endDate.day).add(Duration(days: 1)).toIso8601String()}&transportadora_uuid=2345');
    print(url);
    try {
      final response = await http.get(url,
          headers: {'apiKey': _apiKey!}).timeout(Duration(seconds: 10));
      if (response.statusCode == 204) {
        return;
      }
      final content = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        for (Map<String, dynamic> entrega in content) {
          RemessaState entregaState;
          switch (entrega['status'][0]['status']) {
            case "Recebido":
              entregaState = RemessaState.Recebido;
              break;
            case "Confirmado":
              entregaState = RemessaState.Confirmado;
              break;
            case "Entregado":
              entregaState = RemessaState.Coletado;
              break;
            default:
          }
          Entrega novaEntrega = Entrega(
              id: entrega['id'],
              dtColeta: DateTime.parse(entrega['dataColeta']),
              estadoColeta:
                  ColetaStateConverter.convert(entrega['status'][0]['status']),
              nomeVendedor: "",
              pacotes: []);
          for (Map<String, dynamic> pacote in entrega['pacotes']) {
            Pacote novoPacote = Pacote(
              vendedorName: "",
              id: pacote['id'],
              codPacote: pacote['id'],
              cliente: Comprador(
                id: entrega['id'],
                nome: pacote['destinatario'],
                endereco: pacote['logradouro'],
                bairro: pacote['bairro'],
                cep: pacote['CEP'],
                complemento: pacote['complemento'] ?? "",
              ),
              statusPacotes: [],
            );
            for (var statusEntrega in pacote['status']) {
              novoPacote.statusPacotes.add(
                StatusPacote(
                  timestamp: DateTime.parse(statusEntrega['data']),
                  funcionarioResponsavel: statusEntrega['colaborador']['name'],
                  colaboradorId: statusEntrega['colaborador_uuid'],
                  descricaoStatus: statusEntrega['status'],
                ),
              );
            }
            novaEntrega.pacotes.add(novoPacote);
          }
          _entregas.add(novaEntrega);
        }
        _entregas.sort();
        _entregas = _entregas.reversed.toList();
        notifyListeners();
      } else {
        onError(content['error']);
      }
    } on SocketException catch (socket) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
    } on TimeoutException catch (timeout) {
      onError("Falha na conexão. Tente novamente mais tarde.");
    } on Exception catch (e) {
      onError(e.toString());
    }
  }

  Future<void> postNovaEntrega(Entrega entrega) async {
    final url = Uri.https(ApiURL.apiAuthority, "/entregas");
    final jsonBody = {};
    final response = await http
        .post(url,
            headers: {'apiKey': _apiKey!, 'content-type': 'application/json'},
            body: json.encode(jsonBody))
        .timeout(Duration(seconds: 10));
  }

  Future<bool> postNovaEntregaJson(String jsonBody,
      {required Function onError}) async {
    try {
      final url = Uri.https(ApiURL.apiAuthority, "/entregas");
      final response = await http
          .post(url,
              headers: {'apiKey': _apiKey!, 'content-type': 'application/json'},
              body: jsonBody)
          .timeout(Duration(seconds: 10));
      final content = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        onError(content['error']);
        return false;
      }
    } on SocketException catch (socket) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      return false;
    } on TimeoutException catch (timeout) {
      onError("Falha na conexão. Tente novamente mais tarde.");
      return false;
    } on Exception catch (e) {
      onError(e.toString());
      return false;
    }
  }
}
