//ignore_for_file: todo
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  Future<void> getRemessas({
    required Function onError,
    DateTime? startDate,
    DateTime? endDate,
    RemessaKind? remessaKind,
  }) async {
    _remessas.clear();
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: '/pathToAPI', //TODO Change URL Path
      query: 'query', //TODO Change query
    );
    try {
      final response = await http.get(
        url,
        headers: {'apiKey': apiKey!},
      ).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: unused_local_variable
        final content = json.decode(response.body);
        //TODO: Converter objeto JSON em Remessa
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

  Future<bool> postNovaRemessaJson(
      {required String jsonBody, required Function onError}) async {
    try {
      final url = Uri(
        scheme: 'https',
        host: ApiURL.apiAuthority,
        path: '',
      ); //TODO Set up path
      final response = await http.post(
        url,
        headers: {'apiKey': apiKey!, 'content-type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: unused_local_variable
        final content = json.decode(response.body);
        //TODO: Converter objeto JSON em Remessa
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
