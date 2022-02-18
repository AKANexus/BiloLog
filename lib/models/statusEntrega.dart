class StatusEntrega {
  final int id;
  final DateTime timestamp;
  final String funcionarioResponsavel;
  final String descricaoStatus;

  StatusEntrega({
    required this.id,
    required this.timestamp,
    required this.funcionarioResponsavel,
    required this.descricaoStatus,
  });
}
