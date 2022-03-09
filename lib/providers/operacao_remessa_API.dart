//ignore_for_file: todo
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/pacote.dart';
import '../models/pacote_escaneado.dart';
import '../models/remessa.dart';
import '../env/api_url.dart';

class OperacaoDeRemessaAPI {
  Map<String, dynamic>? authInfo;

  List<InfoPacoteEscaneado>? _pacotesEscaneados;
  List<InfoPacoteEscaneado> get pacotesEscaneados =>
      [..._pacotesEscaneados ?? []];

  Remessa? _remessaVerificada;

  Remessa? _remessa;
  Remessa? get remessa => _remessa;
  List<Pacote> get pacotes => _remessa!.pacotes;

  Pacote? _pacoteDetalhe;
  Pacote? get pacoteDetalhe => _pacoteDetalhe;

  set pacote(Pacote value) {
    _pacoteDetalhe = value;
  }

  set remessa(Remessa? value) {
    if (value != null) {
      _remessa = value;
    }
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

  Future<bool> conferirRemessa({required Function onError}) async {
    _remessaVerificada = null;
    if (_pacotesEscaneados!.isEmpty) {
      onError("Nenhum pacote escaneado");
      return false;
    }
    if (authInfo == null) {
      onError("Informação de autenticação estava em branco");
      return false;
    }
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: '',
    ); //TODO set up path
    final jsonBody = {
      'transportadora_uuid': authInfo!['uuid'],
      'pacotes': _pacotesEscaneados!
          .map((e) => {'id': e.id, 'sender_id': e.senderId, 'size': e.tamanho})
          .toList(),
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'apiKey': authInfo!['apiKey'] as String,
          'content-type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        //TODO: Save [remessaRetornada];
        return true;
      } else {
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        onError(remessaRetornada['error'] ?? "Erro ao conferirRemessa");
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
