import 'dart:convert';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/models/statusEntrega.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ColetasProvider with ChangeNotifier {
  set apiKey(String value) {
    _apiKey = value;
  }

  String? _apiKey;

  List<Coleta> _coletas = [];
  List<Coleta> get coletas => [..._coletas];

  Future<void> getColetas() async {
    _coletas.clear();
    final url = Uri.https("bilolog.herokuapp.com", "/listacoleta");
    //final header = {'apiKey': _apiKey!} as Map<String, String>;
    try {
      final response = await http.get(url,
          headers: {'apiKey': _apiKey!}).timeout(Duration(seconds: 10));
      final content = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        for (Map<String, dynamic> coleta in content) {
          ColetaState coletaState;
          switch (coleta['status'][0]['status']) {
            case "Recebido":
              coletaState = ColetaState.Recebido;
              break;
            case "Confirmado":
              coletaState = ColetaState.Confirmado;
              break;
            case "Coletado":
              coletaState = ColetaState.Coletado;
              break;
            default:
          }
          Coleta novaColeta = Coleta(
              id: coleta['id'],
              dtColeta: DateTime.parse(coleta['dataColeta']),
              estadoColeta:
                  ColetaStateConverter.convert(coleta['status'][0]['status']),
              nomeVendedor: coleta['vendedor']['name'],
              entregas: []);
          for (Map<String, dynamic> pacote in coleta['pacotes']) {
            Entrega novaEntrega = Entrega(
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
              statusEntregas: [],
            );
            for (var statusEntrega in pacote['status']) {
              novaEntrega.statusEntregas.add(
                StatusEntrega(
                  timestamp: DateTime.parse(statusEntrega['data']),
                  funcionarioResponsavel: statusEntrega['colaborador']['name'],
                  colaboradorId: statusEntrega['colaborador_uuid'],
                  descricaoStatus: statusEntrega['status'],
                ),
              );
            }
            novaColeta.entregas.add(novaEntrega);
          }
          _coletas.add(novaColeta);
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> postNovaColeta(Coleta coleta) async {
    final url = Uri.https("bilolog.herokuapp.com", "/listacoleta");
    final jsonBody = {};
    final response = await http
        .post(url,
            headers: {'apiKey': _apiKey!, 'content-type': 'application/json'},
            body: json.encode(jsonBody))
        .timeout(Duration(seconds: 10));
  }

  Future<void> postNovaColetaJson(String jsonBody) async {
    final url = Uri.https("bilolog.herokuapp.com", "/listacoleta");
    final response = await http
        .post(url,
            headers: {'apiKey': _apiKey!, 'content-type': 'application/json'},
            body: jsonBody)
        .timeout(Duration(seconds: 10));
    print(response);
  }
}
