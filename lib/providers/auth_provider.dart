import 'dart:convert';
import 'dart:io';

import 'package:bilolog/env/api_url.dart';
import 'package:bilolog/models/cargo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  String? _apiKey;
  String? _name;
  String? _uuid;
  String? _authorization;
  // String? _error;

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
        return Cargo.galeraDoCD;
      default:
        return Cargo.invalid;
    }
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

  Future<void> logIn(String username, String password, Function onError) async {
    final loginUrl =
        Uri.https(ApiURL.apiAuthority, "/transcolaboradores/login");
    try {
      final apiBody = {
        'username': username,
        'password': password,
      };
      final response = await http
          .post(loginUrl, body: apiBody)
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
        return;
      }
    } on SocketException catch (_) {
      onError("Falha de conexão");
      return;
    } on Exception catch (_) {
      onError("Erro inesperado");
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
