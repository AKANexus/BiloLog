import 'package:bilolog/models/coletaState.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class Recebimento with Comparable<Recebimento> {
  final int id;
  final DateTime dtColeta;
  final String nomeVendedor;
  RemessaState? _estadoColeta;
  final List<Pacote> pacotes;

  Recebimento({
    required this.id,
    required this.dtColeta,
    required this.nomeVendedor,
    required estadoColeta,
    required this.pacotes,
  }) {
    _estadoColeta = estadoColeta;
  }
  int get pacotesColetados {
    return pacotes.length;
  }

  @override
  int compareTo(Recebimento other) {
    return (dtColeta.compareTo(other.dtColeta));
  }

  Map<String, dynamic> get estadoColeta {
    IconData icon;
    String estado;
    switch (_estadoColeta) {
      case RemessaState.Recebido:
        {
          icon = Icons.call_received;
          estado = "Recebido";
          break;
        }
      case RemessaState.Confirmado:
        {
          icon = Icons.check;
          estado = "Confirmado";
          break;
        }
      case RemessaState.Coletado:
        {
          icon = Icons.recommend;
          estado = "Coletado";
          break;
        }
      case RemessaState.EmRota:
        {
          icon = Icons.motorcycle;
          estado = "Em Rota";
          break;
        }
      case RemessaState.Entregue:
        {
          icon = Icons.sentiment_satisfied_alt;
          estado = "Entregue";
          break;
        }
      case RemessaState.EmAnalise:
        {
          icon = Icons.question_mark;
          estado = "Conferindo...";
          break;
        }
      default:
        throw Exception("Estado Recebimento Inválido");
    }
    return {'icon': icon, 'estado': estado};
  }
}
