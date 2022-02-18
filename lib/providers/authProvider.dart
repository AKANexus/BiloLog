import 'dart:convert';
import 'dart:io';

import 'package:bilolog/models/coleta.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthenticationProvider with ChangeNotifier {
  String? _apiKey;
  String? _name;
  String? _uuid;
  String? _authorization;
  String? _error;

  bool get isLoggedIn {
    return (_apiKey != null);
  }

  String get apiKey {
    return _apiKey!;
  }

  Future<void> LogIn(String username, String password, Function onError) async {
    final loginUrl =
        Uri.https("bilolog.herokuapp.com", "/transcolaboradores/login");
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
        _uuid = content['uuid'];
        _authorization = content['authorization'];
        print(_apiKey);
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
}
