import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';

class Coleta {
  final String id;
  final DateTime dtColeta;
  final String nomeVendedor;
  ColetaState? _estadoColeta;
  final List<Entrega> entregas;

  Coleta({
    required this.id,
    required this.dtColeta,
    required this.nomeVendedor,
    required estadoColeta,
    required this.entregas,
  }) {
    _estadoColeta = estadoColeta;
  }
  int get pacotesColetados {
    return entregas.length;
  }

  Map<String, dynamic> get estadoColeta {
    IconData icon;
    String estado;
    switch (_estadoColeta) {
      case ColetaState.Recebido:
        {
          icon = Icons.call_received;
          estado = "Recebido";
          break;
        }
      case ColetaState.Confirmado:
        {
          icon = Icons.check;
          estado = "Confirmado";
          break;
        }
      case ColetaState.Coletado:
        {
          icon = Icons.recommend;
          estado = "Coletado";
          break;
        }
      case ColetaState.EmRota:
        {
          icon = Icons.motorcycle;
          estado = "Em Rota";
          break;
        }
      case ColetaState.Entregue:
        {
          icon = Icons.sentiment_satisfied_alt;
          estado = "Entregue";
          break;
        }
      default:
        throw Exception("Estado Coleta Inválido");
    }
    return {'icon': icon, 'estado': estado};
  }
}
