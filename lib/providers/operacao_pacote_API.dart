import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../env/api_url.dart';
import '../models/remessa.dart';
import 'auth_provider.dart';

class OperacaoDePacoteAPI with ChangeNotifier {
  AuthenticationProvider? authProvider;

  late Pacote pacote;

  Future<bool> entregaPacoteAoCliente({
    required Remessa remessa,
    required Pacote pacote,
    required String nomeRecebedor,
    required String documentoRecebedor,
    required Function onError,
  }) async {
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: 'entrega/entregar',
    );
    final jsonPacote = {
      'pacote': pacote.id.toString(),
      'operacao': remessa.uuid,
      'ml_user_id': pacote.mlUserID,
      'receiver_name': nomeRecebedor,
      'receiver_doc': documentoRecebedor,
    };
    final jsonBody = {
      'pacotes': [jsonPacote],
    };
    try {
      final response = await http
          .post(url,
              headers: {
                'apiKey': authProvider!.apiKey,
                'content-type': 'application/json'
              },
              body: json.encode(jsonBody))
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final content = json.decode(response.body);
        return true;
      } else {
        final content = json.decode(response.body);
        onError(content['error']);
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
