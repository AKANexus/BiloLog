import 'package:bilolog/models/remessa_type.dart';
import 'package:bilolog/models/statusRemessa.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class Remessa with Comparable<Remessa> {
  final int id;
  final DateTime dtRemessa;
  final String? nomeVendedor;
  StatusRemessa? _estadoRemessa;
  List<Pacote> pacotes;
  final RemessaKind remessaKind;

  Remessa(
      {required this.id,
      required this.dtRemessa,
      this.nomeVendedor,
      required estadoRemessa,
      required this.pacotes,
      required this.remessaKind}) {
    _estadoRemessa = estadoRemessa;
  }

  @override
  int compareTo(Remessa other) {
    return (dtRemessa.compareTo(other.dtRemessa));
  }

  int get qtdPacotesProcessados {
    return pacotes.length;
  }

  Map<String, dynamic> get estadoRemessa {
    IconData icon;
    String estado;
    switch (_estadoRemessa) {
      case StatusRemessa.Recebido:
        {
          icon = Icons.call_received;
          estado = "Recebido";
          break;
        }
      case StatusRemessa.Confirmado:
        {
          icon = Icons.check;
          estado = "Confirmado";
          break;
        }
      case StatusRemessa.Coletado:
        {
          icon = Icons.recommend;
          estado = "Coletado";
          break;
        }
      case StatusRemessa.EmRota:
        {
          icon = Icons.motorcycle;
          estado = "Em Rota";
          break;
        }
      case StatusRemessa.Entregue:
        {
          icon = Icons.sentiment_satisfied_alt;
          estado = "Entregue";
          break;
        }
      case StatusRemessa.EmAnalise:
        {
          icon = Icons.question_mark;
          estado = "Conferindo...";
          break;
        }
      default:
        throw Exception("Estado Coleta Inválido");
    }
    return {'icon': icon, 'estado': estado};
  }
}
