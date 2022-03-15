import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/remessa_type.dart';
import 'package:bilolog/models/status_remessa.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/cargo.dart';
import '../models/pacote.dart';
import '../models/pacote_escaneado.dart';
import '../models/remessa.dart';
import '../env/api_url.dart';
import 'auth_provider.dart';

class OperacaoDeRemessaAPI with ChangeNotifier {
  AuthenticationProvider? authProvider;

  List<InfoPacoteEscaneado>? _pacotesEscaneados;
  List<InfoPacoteEscaneado> get pacotesEscaneados =>
      [..._pacotesEscaneados ?? []];

  //Remessa? _remessaVerificada;

  Remessa? _remessa;
  Remessa? get remessa => _remessa;
  List<Pacote> get pacotes => _remessa!.pacotes;
  //List<Pacote> get pacotesVerificados => _remessaVerificada!.pacotes;

  Pacote? _pacoteDetalhe;
  Pacote? get pacoteDetalhe => _pacoteDetalhe;

  set pacote(Pacote? value) {
    _pacoteDetalhe = value;
  }

  set remessa(Remessa? value) {
    if (value != null) {
      _remessa = value;
      notifyListeners();
    }
  }

  String? jsonRetornado;

  List<String> get vendedoresVerificados {
    return pacotes.map((e) => e.vendedorName).toList();
  }

  ///Limpa a lista de pacotes escaneados
  void startNewRemessa() {
    _pacotesEscaneados = [];
  }

  ///Acrescenta um novo [InfoPacoteEscaneado] à lista de pacotes escaneados na
  /// operação de remessa, a não ser que já existe um pacote escaneado
  /// com o mesmo par [sellerId], [senderId]
  void addNovoPacote(String sellerId, int senderId, String tamanho) {
    if (_pacotesEscaneados == null) {
      throw Exception("A remessa não foi iniciada.");
    }

    if (!_pacotesEscaneados!
        .any((x) => x.senderId == senderId && x.id == sellerId)) {
      _pacotesEscaneados!.add(InfoPacoteEscaneado(senderId, sellerId, tamanho));
    }
  }

  String get apiCheckPath {
    if (authProvider == null) throw Exception("Sem informação de autenticação");
    switch (authProvider!.authorization) {
      case Cargo.coletor:
        return "/coleta/check";
      case Cargo.motocorno:
        return "/entrega/check";
      case Cargo.galeraDoCD:
        return "/recebimento/check";
      default:
        throw Exception("Cargo inválido");
    }
  }

  void atualizaStatusPacote(Pacote pacote) {
    _remessa!.pacotes.indexOf(pacote);
    print("sldkjf");
  }

  Future<bool> conferirRemessa({required Function onError}) async {
    _remessa = null;
    if (_pacotesEscaneados!.isEmpty) {
      onError("Nenhum pacote escaneado");
      return false;
    }
    if (authProvider == null) {
      onError("Informação de autenticação estava em branco");
      return false;
    }
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: apiCheckPath,
    );
    final jsonBody = {
      'transportadora_uuid': authProvider!.uuid,
      'pacotes': _pacotesEscaneados!
          .map((e) => {'id': e.id, 'sender_id': e.senderId, 'size': e.tamanho})
          .toList(),
    };
    try {
      final response = await http
          .post(url,
              headers: {
                'apiKey': authProvider!.apiKey,
                'content-type': 'application/json',
              },
              body: json.encode(jsonBody))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonRetornado = response.body;
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        _remessa = Remessa(
            uuid: "-1",
            dtRemessa: DateTime.now(),
            estadoRemessa: StatusRemessa.emAnalise,
            pacotes: [],
            remessaKind: RemessaKind.coleta);
        for (Map<String, dynamic> pacote in remessaRetornada['pacotes']) {
          if (pacote['error'] != null) {
            _remessa!.pacotes.add(
              Pacote(
                id: "N/A",
                codPacote: "N/A",
                cliente: Comprador(
                    id: -1,
                    nome: "",
                    endereco: "",
                    bairro: "",
                    cep: "",
                    complemento: ""),
                statusPacotes: [],
                vendedorName: "",
                errorMessage: pacote['error'],
              ),
            );
          } else {
            _remessa!.pacotes.add(Pacote(
                id: pacote['id'],
                codPacote: pacote['id'],
                cliente: Comprador(
                    id: -1,
                    nome: pacote['destinatario'],
                    endereco: pacote['logradouro'],
                    bairro: pacote['bairro'],
                    cep: pacote['CEP'],
                    complemento: pacote['complemento']),
                statusPacotes: [],
                vendedorName: "ABELARDO"));
          }
        }
        return true;
      } else {
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        onError(remessaRetornada['error']['code'] ?? "Erro ao conferirRemessa");
        return false;
      }
    } on SocketException catch (_) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      return false;
    } on TimeoutException catch (_) {
      onError("Falha na conexão. Tente novamente mais tarde.");
      return false;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }
}
