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
          switch (coleta['statusLista']) {
            case "Recebido":
              coletaState = ColetaState.Recebido;
              break;
            case "Confirmado":
              coletaState = ColetaState.Confirmado;
              break;
            case "Coletado":

            default:
          }
          Coleta novaColeta = Coleta(
              id: coleta['idColeta'],
              dtColeta:
                  DateTime.fromMillisecondsSinceEpoch(coleta['dataColeta']),
              estadoColeta: ColetaStateConverter.convert(coleta['statusLista']),
              nomeVendedor: coleta['nomeCliente'],
              entregas: []);
          for (Map<String, dynamic> pacote in coleta['pacotes']) {
            Entrega novaEntrega = Entrega(
              id: pacote['idPacote'],
              codPacote: pacote['idPacote'],
              cliente: Vendedor(
                id: coleta['idCliente'],
                nome: pacote['destinatario'],
                endereco: pacote['logradouro'],
                bairro: pacote['bairro'],
                cep: pacote['CEP'].toString(),
                complemento: pacote['complemento'],
              ),
              statusEntregas: [],
            );
            for (var statusEntrega in pacote['status']) {
              novaEntrega.statusEntregas.add(
                StatusEntrega(
                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                      statusEntrega['statusData']),
                  funcionarioResponsavel: statusEntrega['nomeColaborador'],
                  colaboradorId: statusEntrega['colaborador_id'],
                  descricaoStatus: statusEntrega['statusPacote'],
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
}
