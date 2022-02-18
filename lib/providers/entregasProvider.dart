import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

class EntregasProvider with ChangeNotifier {
  List<Entrega> _entregas = [];

  List<Entrega> get entregas => [..._entregas];
}
