import 'package:bilolog/models/coleta.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ColetasProvider with ChangeNotifier {
  set apiKey(String value) {
    _apiKey = value;
  }

  String? _apiKey;

  List<Coleta> _coletas = [];

  List<Coleta> get coletas => [..._coletas];

  Future<void> getColetas() async {
    final url = Uri.https("bilolog.herokuapp.com", "/listacoleta");
    //final header = {'apiKey': _apiKey!} as Map<String, String>;
    try {
      final response = http.get(url,
          headers: {'apiKey': _apiKey!}).timeout(Duration(seconds: 5));
    } catch (e) {}
  }
}
