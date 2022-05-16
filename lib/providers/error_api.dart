import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/env/api_url.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ErrorsAPI {
  String? get apiKey => authProvider?.apiKey;

  AuthenticationProvider? authProvider;

  Future<bool> postNovoError(
      {Exception? exception,
      String? operacao,
      int? pacote,
      int? integracao,
      String? code,
      String? apiResponse,
      String? message,
      StackTrace? stackTrace,
      String? source}) async {
    try {
      final url = Uri(
        scheme: 'https',
        host: ApiURL.apiAuthority,
        path: '/deumerda',
      );
      final jsonBody = {
        'colaborador': authProvider?.uuid,
        'operacao': operacao,
        'pacote': pacote,
        'integracao': pacote,
        'code': code,
        'apiResponse': apiResponse,
        'message': exception != null ? exception.toString() : message,
        'stackTrace': stackTrace.toString(),
        'source': source,
        'timestamp': DateTime.now()
      };
      final response = await http
          .post(url,
              headers: {'apiKey': apiKey!, 'content-type': 'application/json'},
              body: jsonBody)
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final content = json.decode(response.body);
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } on Exception catch (e) {
      return false;
    }
    return false;
  }
}
