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
      final content = json.decode(
          '[{"idColeta":"0b4d5e64-40a3-4eb0-a8eb-3062bc144f1d","dataColeta":1645561126580,"idCliente":"0d83c4fb-1eda-45c3-90e5-7b047897bebe","nomeCliente":"Adenerrbaldo Geristronio LTDA","qtdPacotes":75,"statusLista":"Recebido","createdAt":1645561126580,"updatedAt":1645561126580,"transportadora_id":"ba2ac3a2-bca4-40dc-9594-48a1d843e3fe","coletor_id":"71354173-649a-415e-a926-01a2a04ad38a","coletor":{"idColetor":"71354173-649a-415e-a926-01a2a04ad38a","nomeColetor":"Motocorno aleatório","telefoneColetor":"11963658547","transportadora_id":"ba2ac3a2-bca4-40dc-9594-48a1d843e3fe"},"pacotes":[{"idPacote":41181641070,"destinatario":"José Serra","logradouro":"Rua Bento de barros 300","bairro":"Jd Amaralina","CEP":"05570200","complemento":"Casa da sua mãe","observacoes":"Comendo ela, claro!","status":[{"statusData":1645561126580,"statusPacote":"Coletado","colaborador_id":"eba06d22-1178-4767-b133-90f3725e5249","nomeColaborador":"Girafa anonima"},{"statusData":1645561126580,"statusPacote":"Recebido","colaborador_id":"eba06d22-1178-4767-b133-90f3725e5249","nomeColaborador":"Girafa anonima"},{"statusData":1645561126580,"statusPacote":"Em rota","colaborador_id":"eba06d22-1178-4767-b133-90f3725e5249","nomeColaborador":"Girafa anonima"},{"statusData":1645561126580,"statusPacote":"Entregue","colaborador_id":"eba06d22-1178-4767-b133-90f3725e5249","nomeColaborador":"Girafa anonima"}]}]}]');
      //json.decode(response.body);
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
              cliente: Comprador(
                id: coleta['idCliente'],
                nome: pacote['destinatario'],
                endereco: pacote['logradouro'],
                bairro: pacote['bairro'],
                cep: pacote['CEP'].toString(),
                complemento: pacote['complemento'] ?? "",
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
