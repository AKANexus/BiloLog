import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/statusEntrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../env/apiUrl.dart';

class ColetasProvider with ChangeNotifier {
  set apiKey(String value) {
    _apiKey = value;
  }

  String? _apiKey;

  List<Coleta> _coletas = [];
  List<Coleta> get coletas => [..._coletas];

  Future<void> getColetas(
      Function onError, DateTime startDate, DateTime endDate) async {
    _coletas.clear();
    final url = Uri(
        scheme: 'https',
        host: ApiURL.apiAuthority,
        path: '/listacoleta/',
        query:
            'dateStart=${DateTime(startDate.year, startDate.month, startDate.day).toIso8601String()}&dateEnd=${DateTime(endDate.year, endDate.month, endDate.day).add(Duration(days: 1)).toIso8601String()}');
    print(url);
    try {
      final response = await http.get(url,
          headers: {'apiKey': _apiKey!}).timeout(Duration(seconds: 10));
      final content = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        for (Map<String, dynamic> coleta in content) {
          RemessaState coletaState;
          switch (coleta['status'][0]['status']) {
            case "Recebido":
              coletaState = RemessaState.Recebido;
              break;
            case "Confirmado":
              coletaState = RemessaState.Confirmado;
              break;
            case "Coletado":
              coletaState = RemessaState.Coletado;
              break;
            default:
          }
          Coleta novaColeta = Coleta(
              id: coleta['id'],
              dtColeta: DateTime.parse(coleta['dataColeta']),
              estadoColeta:
                  ColetaStateConverter.convert(coleta['status'][0]['status']),
              nomeVendedor: coleta['vendedor']['name'],
              pacotes: []);
          for (Map<String, dynamic> pacote in coleta['pacotes']) {
            Pacote novoPacote = Pacote(
              vendedorName: coleta['vendedor']['name'],
              id: pacote['id'],
              codPacote: pacote['id'],
              cliente: Comprador(
                id: coleta['id'],
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
            novaColeta.pacotes.add(novoPacote);
          }
          _coletas.add(novaColeta);
        }
        _coletas.sort();
        _coletas = _coletas.reversed.toList();
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

  Future<void> postNovaColeta(Coleta coleta) async {
    final url = Uri.https(ApiURL.apiAuthority, "/listacoleta");
    final jsonBody = {};
    final response = await http
        .post(url,
            headers: {'apiKey': _apiKey!, 'content-type': 'application/json'},
            body: json.encode(jsonBody))
        .timeout(Duration(seconds: 10));
  }

  Future<bool> postNovaColetaJson(String jsonBody,
      {required Function onError}) async {
    try {
      final url = Uri.https(ApiURL.apiAuthority, "/listacoleta");
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
