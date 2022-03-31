import 'package:bilolog/models/remessa_type.dart';
import 'package:bilolog/models/status_remessa.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';

class Remessa with Comparable<Remessa> {
  final String uuid;
  final DateTime dtRemessa;
  final String? nomeVendedor;
  final String nomeColaborador;
  StatusRemessa? _estadoRemessa;
  List<Pacote> pacotes;
  final RemessaKind remessaKind;

  Remessa(
      {required this.uuid,
      required this.dtRemessa,
      this.nomeVendedor,
      required this.nomeColaborador,
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
      case StatusRemessa.finalizado:
        {
          icon = Icons.call_received;
          estado = "Finalizado";
          break;
        }
      case StatusRemessa.confirmado:
        {
          icon = Icons.check;
          estado = "Confirmado";
          break;
        }
      case StatusRemessa.coletado:
        {
          icon = Icons.recommend;
          estado = "Coletado";
          break;
        }
      case StatusRemessa.emRota:
        {
          icon = Icons.motorcycle;
          estado = "Em Rota";
          break;
        }
      case StatusRemessa.entregue:
        {
          icon = Icons.sentiment_satisfied_alt;
          estado = "Entregue";
          break;
        }
      case StatusRemessa.pendente:
        {
          icon = Icons.not_listed_location;
          estado = "Pendente...";
          break;
        }
      default:
        throw Exception("Estado Coleta Inválido");
    }
    return {'icon': icon, 'estado': estado};
  }
}
