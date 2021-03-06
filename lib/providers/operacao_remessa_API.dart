import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/exceptions/location_denied_exception.dart';
import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/location_coords.dart';
import 'package:bilolog/models/status_pacote.dart';
import 'package:bilolog/providers/error_api.dart';
import 'package:bilolog/providers/location_provider.dart';
import 'package:bilolog/models/remessa_type.dart';
import 'package:bilolog/models/status_remessa.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

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
  final location = LocationProvider();
  Remessa? _remessa;
  Remessa? get remessa => _remessa;
  List<Pacote> get pacotes => _remessa!.pacotes;
  List<Pacote> get pacotesComErro =>
      _remessa!.pacotes.where((element) => element.hasError).toList();
  //List<Pacote> get pacotesVerificados => _remessaVerificada!.pacotes;

  final errorsapi = ErrorsAPI();

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
    if (authProvider == null) {
      errorsapi.postNovoError(
          source: 'apiPostPath()', message: 'authProvider era nulo.');
      throw Exception("Sem informação de autenticação");
    }
    switch (authProvider!.authorization) {
      case Cargo.coletor:
        return "/coleta/check";
      case Cargo.motocorno:
        return "/entrega/check";
      case Cargo.galeraDoCD:
        return "/recebimento/check";
      case Cargo.supervisor:
        switch (authProvider!.specialAuth) {
          case Cargo.coletor:
            return "/coleta/check";
          case Cargo.galeraDoCD:
            return "/recebimento/check";
          default:
            errorsapi.postNovoError(
                source: 'apiGetPath',
                message: 'Supervisor com special auth inválido: ' +
                    authProvider!.specialAuth.toString());
            throw Exception("Cargo inválido");
        }
      default:
        errorsapi.postNovoError(
            source: 'apiGetPath',
            message:
                'Auth inválido: ' + authProvider!.authorization.toString());
        throw Exception("Cargo inválido");
    }
  }

  void atualizaStatusPacote(Pacote pacote, StatusPacote status) {
    final pacoteIx = _remessa!.pacotes.indexOf(pacote);
    _remessa!.pacotes[pacoteIx].statusPacotes.insert(0, status);
    notifyListeners();
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
      // port: 5200,
    );
    late LocationData userLocation;
    try {
      userLocation = await location.getCurrentLocation();
    } on LocationDeniedException catch (lde) {
      onError(lde.deniedForever
          ? "A localização do dispositivo é necessária para a utilização desse aplicativo. Altere as permissões no app de Configurações e tente novamente."
          : "A localização do dispositivo é necessária para a utilização desse aplicativo. Tente novamente.");
      return false;
    }
    final jsonBody = {
      'transportadora_uuid': authProvider!.uuid,
      'pacotes': _pacotesEscaneados!
          .map((e) => {'id': e.id, 'sender_id': e.senderId, 'size': e.tamanho})
          .toList(),
      'latitude': userLocation.latitude,
      'longitude': userLocation.longitude,
    };
    try {
      final response = await http
          .post(url,
              headers: {
                'apiKey': authProvider!.apiKey,
                'content-type': 'application/json',
              },
              body: json.encode(jsonBody))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        jsonRetornado = response.body;
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        _remessa = Remessa(
            uuid: "-1",
            dtRemessa: DateTime.now(),
            estadoRemessa: StatusRemessa.emAnalise,
            pacotes: [],
            nomeColaborador: "",
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
                location: LocationCoords(0, 0),
                errorMessage: (pacote['message'] is String)
                    ? "${pacote['message']}"
                    : "${pacote['error']}, status atual: ${pacote['statusPacote']}",
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
                location: LocationCoords(0, 0),
                vendedorName: "ABELARDO"));
          }
        }
        return true;
      } else {
        final Map<String, dynamic> remessaRetornada =
            json.decode(response.body);
        errorsapi.postNovoError(
            code: remessaRetornada['code'],
            message: remessaRetornada['message'],
            apiResponse: remessaRetornada.toString(),
            source:
                'conferirRemessa()\nRemessa enviada: ' + jsonBody.toString());
        onError(remessaRetornada['code'] ??
            remessaRetornada['message'] ??
            remessaRetornada['error'] ??
            "Erro ao retornar remessa");
        return false;
      }
    } on SocketException catch (e, stacktrace) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      errorsapi.postNovoError(
          exception: e,
          stackTrace: stacktrace,
          message: "Falha de conexão.\nVerifique sua conexão à internet.",
          source: 'conferirRemessa()\nRemessa enviada: ' + jsonBody.toString());
      return false;
    } on TimeoutException catch (e, stacktrace) {
      onError("Falha na conexão. Tente novamente mais tarde.");
      errorsapi.postNovoError(
          exception: e,
          stackTrace: stacktrace,
          message: "Falha na conexão. Tente novamente mais tarde.",
          source: 'conferirRemessa()\nRemessa enviada: ' + jsonBody.toString());
      return false;
    } on Exception catch (e, stacktrace) {
      onError(e.toString());
      errorsapi.postNovoError(
          exception: e,
          stackTrace: stacktrace,
          source: 'conferirRemessa()\nRemessa enviada: ' + jsonBody.toString());
      return false;
    }
  }
}
