import 'dart:convert';
import 'dart:io';

import 'package:bilolog/env/apiUrl.dart';
import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  String? _apiKey;
  String? _name;
  String? _uuid;
  String? _authorization;
  String? _error;

  bool get isLoggedIn {
    return (_apiKey != null);
  }

  Cargo get authorization {
    switch (_authorization) {
      case "motocorno":
        return Cargo.Motocorno;
      case "coletor":
        return Cargo.Coletor;
      default:
        return Cargo.INVALID;
    }
  }

  String get apiKey {
    return _apiKey ?? "";
  }

  String get uuid {
    return _uuid ?? "";
  }

  Future<void> LogOut() async {
    _apiKey = null;
    _name = null;
    _uuid = null;
    _authorization = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await prefs.remove('apiKey');

    notifyListeners();
  }

  Future<void> LogIn(String username, String password, Function onError) async {
    final loginUrl =
        Uri.https(ApiURL.apiAuthority, "/transcolaboradores/login");
    try {
      final apiBody = {
        'username': username,
        'password': password,
      };
      final response = await http
          .post(loginUrl, body: apiBody)
          .timeout(Duration(seconds: 5));
      final content = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _apiKey = content['apiKey'];
        _name = content['name'];
        _uuid = content['transportadora']['uuid'];
        _authorization = content['authorization'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('apiKey', _apiKey!);
        await prefs.setString('uuid', _uuid!); //Alterar para int
        await prefs.setString('name', _name!);
        await prefs.setString('authorization', _authorization!);
        notifyListeners();
        return;
      } else {
        onError(content['error']);
        return;
      }
    } on SocketException catch (se) {
      onError("Falha de conexão");
      return;
    } on Exception catch (e) {
      onError("Erro inesperado");
      return;
    }
  }

  Future<void> CheckForLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await prefs.get('apiKey') as String?;
    if (apiKey != null) {
      _apiKey = apiKey;
      _authorization = await prefs.get('authorization') as String;
      _name = await prefs.get('name') as String;
      _uuid = await prefs.get('uuid') as String;
      notifyListeners();
    }
  }
}
