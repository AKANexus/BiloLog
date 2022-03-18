import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/models/cliente.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/status_pacote.dart';
import 'package:bilolog/models/status_remessa.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/remessa.dart';
import '../models/remessa_type.dart';
import '../env/api_url.dart';

class RemessasAPI with ChangeNotifier {
  String? get apiKey => authProvider?.apiKey;

  AuthenticationProvider? authProvider;

  // ignore: prefer_final_fields
  List<Remessa> _remessas = [];
  List<Remessa> get remessas => [..._remessas];

  String get apiGetPath {
    if (authProvider == null) throw Exception("Sem informação de autenticação");
    switch (authProvider!.authorization) {
      case Cargo.coletor:
        return "/coleta";
      case Cargo.motocorno:
        return "/entrega";
      case Cargo.galeraDoCD:
        return "/recebimento";
      default:
        throw Exception("Cargo inválido");
    }
  }

  Future<void> getRemessas({
    required Function onError,
    DateTime? startDate,
    DateTime? endDate,
    RemessaKind? remessaKind,
  }) async {
    _remessas.clear();

    startDate ??= DateTime.now();
    endDate ??= DateTime.now();
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: apiGetPath,
      query:
          'dateStart=${DateTime(startDate.year, startDate.month, startDate.day).toIso8601String()}&dateEnd=${DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1)).toIso8601String()}',
    );
    try {
      final response = await http.get(
        url,
        headers: {'apiKey': apiKey!},
      ).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final content = json.decode(response.body);

        for (Map<String, dynamic> coleta in content) {
          Remessa novaRemessa = Remessa(
            uuid: coleta['uuid'],
            dtRemessa: DateTime.parse(
                (coleta['createdAt'] as String).replaceAll("Z", "+03")),
            estadoRemessa: ColetaStateConverter.convert(coleta['status']),
            pacotes: [],
            remessaKind: RemessaKindConverter.convert(coleta['type']),
            nomeVendedor: coleta['vendedor'][0]['contact_name'],
          );
          for (Map<String, dynamic> pacote in coleta['pacotes']) {
            Pacote novoPacote = Pacote(
                id: pacote['id'],
                codPacote: pacote['id'],
                mlUserID: pacote['ml_user_id'],
                cliente: Comprador(
                    id: -1,
                    nome: pacote['destinatario'],
                    endereco: pacote['logradouro'],
                    bairro: pacote['bairro'],
                    cep: pacote['CEP'],
                    complemento: pacote['complemento']),
                statusPacotes: [],
                vendedorName: coleta['vendedor'][0]['contact_name']);
            for (Map<String, dynamic> status in pacote['status']) {
              novoPacote.statusPacotes.add(StatusPacote(
                  timestamp: DateTime.parse(
                      (status['createdAt'] as String).replaceAll("Z", "+03")),
                  funcionarioResponsavel: status['colaborador']['name'],
                  colaboradorId: status['colaborador']['uuid'],
                  descricaoStatus: status['status']));
            }
            novaRemessa.pacotes.add(novoPacote);
          }
          _remessas.add(novaRemessa);
        }
        _remessas.sort();
        _remessas = _remessas.reversed.toList();
        notifyListeners();

        return;
      }
      if (response.statusCode == 204) {
        onError("Nenhuma remessa encontrada para os filtros informados");
        notifyListeners();
        return;
      } else {
        final content = json.decode(response.body);
        onError(content['error']);
        notifyListeners();
        return;
      }
    } on SocketException catch (_) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
    } on TimeoutException catch (_) {
      onError("Falha na conexão. Tente novamente mais tarde.");
    } on Exception catch (e) {
      onError(e.toString());
    }
  }

  String get apiPostPath {
    if (authProvider == null) throw Exception("Sem informação de autenticação");
    switch (authProvider!.authorization) {
      case Cargo.coletor:
        return "/coleta/create";
      case Cargo.motocorno:
        return "/entrega/create";
      case Cargo.galeraDoCD:
        return "/recebimento/create";
      default:
        throw Exception("Cargo inválido");
    }
  }

  Future<bool> postNovaRemessaJson(
      {required String jsonBody, required Function onError}) async {
    try {
      final url = Uri(
        scheme: 'https',
        host: ApiURL.apiAuthority,
        path: apiPostPath,
      );
      final response = await http
          .post(url,
              headers: {'apiKey': apiKey!, 'content-type': 'application/json'},
              body: jsonBody)
          .timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: unused_local_variable
        final content = json.decode(response.body);

        notifyListeners();
        return true;
      }
      if (response.statusCode == 204) {
        onError("Nenhuma remessa encontrada para os filtros informados");
        notifyListeners();
        return true;
      } else {
        final content = json.decode(response.body);
        onError(content['error']);
        notifyListeners();
        return false;
      }
    } on SocketException catch (_) {
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      return false;
    } on TimeoutException catch (_) {
      onError("Falha na conexão. Tente novamente mais tarde.");
      return false;
    } on Exception catch (e) {
      onError(e.toString());
      return false;
    }
  }
}
