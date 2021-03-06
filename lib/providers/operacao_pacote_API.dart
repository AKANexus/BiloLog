import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:bilolog/models/pacote.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../env/api_url.dart';
import '../models/remessa.dart';
import 'auth_provider.dart';
import 'error_api.dart';

class OperacaoDePacoteAPI with ChangeNotifier {
  AuthenticationProvider? authProvider;

  late Pacote pacote;
  final errorapi = ErrorsAPI();

  Future<bool> problemaAoEntregarPacote(
      {required Remessa remessa,
      required Pacote pacote,
      required double latitude,
      required double longitude,
      required Map<String, dynamic> dados,
      required Function onError}) async {
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: 'entrega/problemas',
      // port: 5200,
    );
    final mpPacote = {
      'pacote': pacote.id.toString(),
      'operacao': remessa.uuid,
      'ml_user_id': pacote.mlUserID,
      'receiver_name': 'Não Entregue',
      'latitude': latitude,
      'longitude': longitude,
    };
    //if (dados != null)
    {
      mpPacote['observacoes'] = dados['observacao'];
    }
    final mpBody = {
      'pacotes': [mpPacote],
    };
    //debugger();

    //final picture = await rootBundle.load('lib/assets/test_RemoveMe/test.jpg');

    // final teste1 = await getExternalStorageDirectory();
    // String _localPath = teste1!.path;
    // String filePath = _localPath + "/lady.jpeg";

    // final newFile =
    //     await io.File(filePath).copy(filePath.replaceAll(".jpeg", ".jpg"));

    try {
      var headers = {'apiKey': authProvider!.apiKey};
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({'pacote': json.encode(mpBody)});
      if (
          //dados != null &&
          dados['images'] != null) {
        for (var file in dados['images'] as List<XFile>) {
          final mpFile = await http.MultipartFile.fromPath('photos', file.path);
          request.files.add(mpFile);
        }
      }
      // final mpFile = await http.MultipartFile.fromPath('photos', newFile.path);
      // request.files.add(mpFile);

      request.headers.addAll(headers);

      http.StreamedResponse response =
          await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        //debugger();
        //print(await response.stream.bytesToString());
        return true;
      } else {
        //debugger();
        //print(response.reasonPhrase);
        final errorMessage = await response.stream.bytesToString();
        onError(errorMessage);
        errorapi.postNovoError(
          source: 'problemaAoEntregarPacote()\nDados enviados:\n ' +
              mpBody.toString(),
          apiResponse: errorMessage,
          code: response.statusCode.toString(),
          pacote: int.parse(pacote.id),
          operacao: remessa.uuid,
        );
        return false;
      }
    }
    // try {
    //   final request = http.MultipartRequest('POST', url);
    //   request.fields['pacote'] = json.encode(mpBody);

    //   if (dados != null) {
    //     for (var photo in dados['images'] as List<XFile>) {
    //       request.files
    //           .add(await http.MultipartFile.fromPath('photos', photo.path));
    //     }
    //   }
    //   final header = {
    //     'apiKey': authProvider!.apiKey,
    //   };
    //   request.headers.addAll(header);
    //   debugger();
    //   final response =
    //       await request.send().timeout(const Duration(seconds: 10));
    //   if (response.statusCode >= 200 && response.statusCode <= 299) {
    //     return true;
    //   } else {
    //     debugger();
    //     final sifuder = await response.stream.bytesToString();
    //     final content = json.decode(sifuder);
    //     onError("content['error']");
    //     return false;
    //   }
    // }
    on io.SocketException catch (e, stacktrace) {
      //debugger();
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      errorapi.postNovoError(
        source: 'problemaAoEntregarPacote()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha de conexão.\nVerifique sua conexão à internet.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    } on TimeoutException catch (e, stacktrace) {
      //debugger();
      onError("Falha na conexão. Tente novamente mais tarde.");
      errorapi.postNovoError(
        source: 'problemaAoEntregarPacote()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha na conexão. Tente novamente mais tarde.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    } on Exception catch (e, stacktrace) {
      //debugger();
      onError(e.toString());
      onError("Falha na conexão. Tente novamente mais tarde.");
      errorapi.postNovoError(
        source: 'problemaAoEntregarPacote()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha na conexão. Tente novamente mais tarde.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    }
  }

  Future<bool> entregaPacoteAoClienteMP({
    required Remessa remessa,
    required Pacote pacote,
    required String nomeRecebedor,
    required String documentoRecebedor,
    required Function onError,
    Map<String, dynamic>? dados,
    double latitude = 43.645074,
    double longitude = -115.993081,
  }) async {
    final url = Uri(
      scheme: 'https',
      host: ApiURL.apiAuthority,
      path: 'entrega/entregar',
      // port: 5200,
    );
    final mpPacote = {
      'pacote': pacote.id.toString(),
      'operacao': remessa.uuid,
      'ml_user_id': pacote.mlUserID,
      'receiver_name': nomeRecebedor,
      'receiver_doc': documentoRecebedor,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (dados != null) {
      mpPacote['observacoes'] = dados['observacao'];
    }
    final mpBody = {
      'pacotes': [mpPacote],
    };
    //debugger();

    //final picture = await rootBundle.load('lib/assets/test_RemoveMe/test.jpg');

    // final teste1 = await getExternalStorageDirectory();
    // String _localPath = teste1!.path;
    // String filePath = _localPath + "/lady.jpeg";

    // final newFile =
    //     await io.File(filePath).copy(filePath.replaceAll(".jpeg", ".jpg"));

    try {
      var headers = {'apiKey': authProvider!.apiKey};
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({'pacote': json.encode(mpBody)});
      if (dados != null && dados['images'] != null) {
        for (var file in dados['images'] as List<XFile>) {
          final mpFile = await http.MultipartFile.fromPath('photos', file.path);
          request.files.add(mpFile);
        }
      }
      // final mpFile = await http.MultipartFile.fromPath('photos', newFile.path);
      // request.files.add(mpFile);

      request.headers.addAll(headers);

      http.StreamedResponse response =
          await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        //debugger();
        //print(await response.stream.bytesToString());
        return true;
      } else {
        //debugger();
        final errorMessage = await response.stream.bytesToString();
        //print(errorMessage);
        errorapi.postNovoError(
          source: 'entregaPacoteAoClienteMP()\nDados enviados:\n ' +
              mpBody.toString(),
          apiResponse: errorMessage,
          code: response.statusCode.toString(),
          pacote: int.parse(pacote.id),
          operacao: remessa.uuid,
        );
        onError(errorMessage);
        return false;
      }
    }
    // try {
    //   final request = http.MultipartRequest('POST', url);
    //   request.fields['pacote'] = json.encode(mpBody);

    //   if (dados != null) {
    //     for (var photo in dados['images'] as List<XFile>) {
    //       request.files
    //           .add(await http.MultipartFile.fromPath('photos', photo.path));
    //     }
    //   }
    //   final header = {
    //     'apiKey': authProvider!.apiKey,
    //   };
    //   request.headers.addAll(header);
    //   debugger();
    //   final response =
    //       await request.send().timeout(const Duration(seconds: 10));
    //   if (response.statusCode >= 200 && response.statusCode <= 299) {
    //     return true;
    //   } else {
    //     debugger();
    //     final sifuder = await response.stream.bytesToString();
    //     final content = json.decode(sifuder);
    //     onError("content['error']");
    //     return false;
    //   }
    // }
    on io.SocketException catch (e, stacktrace) {
      //debugger();
      onError("Falha de conexão.\nVerifique sua conexão à internet.");
      errorapi.postNovoError(
        source: 'entregaPacoteAoClienteMP()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha de conexão.\nVerifique sua conexão à internet.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    } on TimeoutException catch (e, stacktrace) {
      //debugger();
      onError("Falha na conexão. Tente novamente mais tarde.");
      errorapi.postNovoError(
        source: 'entregaPacoteAoClienteMP()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha na conexão. Tente novamente mais tarde.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    } on Exception catch (e, stacktrace) {
      //debugger();
      onError(e.toString());
      onError("Falha na conexão. Tente novamente mais tarde.");
      errorapi.postNovoError(
        source: 'entregaPacoteAoClienteMP()\nDados enviados:\n ' +
            mpBody.toString(),
        exception: e,
        stackTrace: stacktrace,
        message: "Falha na conexão. Tente novamente mais tarde.",
        pacote: int.parse(pacote.id),
        operacao: remessa.uuid,
      );
      return false;
    }
  }
}
