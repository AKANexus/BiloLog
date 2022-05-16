import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/env/api_url.dart';
import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/error_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  String? _apiKey;
  String? _name;
  String? _uuid;
  String? _authorization;
  Cargo _specialAuth = Cargo.coletor;
  // String? _error;

  final errorapi = ErrorsAPI();

  bool get isLoggedIn {
    return (_apiKey != null);
  }

  Cargo get authorization {
    switch (_authorization) {
      case "motocorno":
        return Cargo.motocorno;
      case "coletor":
        return Cargo.coletor;
      case "interno":
        return Cargo.galeraDoCD;
      case "supervisor":
        return Cargo.supervisor;
      case "administrador":
        return Cargo.administrador;
      default:
        return Cargo.invalid;
    }
  }

  Cargo get specialAuth {
    return _specialAuth;
  }

  set specialAuth(Cargo value) {
    _specialAuth = value;
    notifyListeners();
  }

  String get apiKey {
    return _apiKey ?? "";
  }

  String get uuid {
    return _uuid ?? "";
  }

  Future<void> logOut() async {
    _apiKey = null;
    _name = null;
    _uuid = null;
    _authorization = null;
    //_error = null;
    final prefs = await SharedPreferences.getInstance();
    //final apiKey =
    await prefs.remove('apiKey');

    notifyListeners();
  }

  Future<void> teste(BuildContext context) async {
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: 'entrega/entregar',
      // port: 5200,
    );
    final mpPacote = {
      'pacote': "potaria",
      'operacao': "remessa.uuid",
      'ml_user_id': "pacote.mlUserID",
      'receiver_name': "nomeRecebedor",
      'receiver_doc': "documentoRecebedor",
      'latitude': 1,
      'longitude': -1,
    };

    mpPacote['observacoes'] = "dados['observacao']";
    //final picture = await rootBundle.load('lib/assets/test_RemoveMe/test.jpg');

    final teste1 = await getExternalStorageDirectory();
    String _localPath = teste1!.path;
    String filePath = _localPath + "/arquivoDeTeste".trim() + "_" + ".jpeg";

    final mpBody = {
      'pacotes': [mpPacote],
    };
    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['pacote'] = json.encode(mpBody);
      for (var i = 0; i < 5; i++) {
        request.files
            .add(await http.MultipartFile.fromPath('photos', filePath));
      }

      final response =
          await request.send().timeout(const Duration(seconds: 1000));
      //final responseBody =
      await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Response code: ${response.statusCode}")));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Exception: ${e.toString()}")));
    }
  }

  Future<void> logIn(String username, String password, Function onError) async {
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: 'transcolaboradores/login',
      // port: 5200,
    );

    final apiBody = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http
          .post(url, body: apiBody)
          .timeout(const Duration(seconds: 5));
      final content = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _apiKey = content['apiKey'];
        _name = content['name'];
        _uuid = content['transportadora']['uuid'];
        _authorization = content['authorization'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('apiKey', _apiKey!);
        prefs.setString('uuid', _uuid!); //Alterar para int
        prefs.setString('name', _name!);
        prefs.setString('authorization', _authorization!);
        notifyListeners();
        return;
      } else {
        onError(content['error']);
        errorapi.postNovoError(
          source: 'login(): ' + apiBody.toString(),
          apiResponse: response.body,
        );
        return;
      }
    } on SocketException catch (e, stacktrace) {
      onError("Falha de conexão");
      errorapi.postNovoError(
        source: 'login(): ' + apiBody.toString(),
        exception: e,
        stackTrace: stacktrace,
      );
      return;
    } on Exception catch (e, stacktrace) {
      onError("Erro inesperado: ${e.toString()}");
      errorapi.postNovoError(
        source: 'login(): ' + apiBody.toString(),
        exception: e,
        stackTrace: stacktrace,
      );
      return;
    }
  }

  Future<void> checkForLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.get('apiKey') as String?;
    if (apiKey != null) {
      _apiKey = apiKey;
      _authorization = prefs.get('authorization') as String;
      _name = prefs.get('name') as String;
      _uuid = prefs.get('uuid') as String;
      notifyListeners();
    }
  }
}
