enum StatusRemessa {
  confirmado,
  coletado,
  recebido,
  emRota,
  entregue,
  emAnalise,
  pendente
}

class ColetaStateConverter {
  static StatusRemessa convert(String state) {
    // StatusRemessa convertido;
    switch (state.toLowerCase()) {
      case "pendente":
        return StatusRemessa.pendente;
      case "recebido":
        return StatusRemessa.recebido;
      case "confirmado":
        return StatusRemessa.confirmado;
      case "coletado":
        return StatusRemessa.coletado;
      case "em rota":
        return StatusRemessa.emRota;
      case "entregue":
        return StatusRemessa.entregue;
      default:
        // print("State was $state");
        throw ArgumentError("O argumento informado não era esperado", "state");
    }
  }
}
