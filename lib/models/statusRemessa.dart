enum StatusRemessa {
  Confirmado,
  Coletado,
  Recebido,
  EmRota,
  Entregue,
  EmAnalise
}

class ColetaStateConverter {
  static StatusRemessa convert(String state) {
    StatusRemessa convertido;
    switch (state.toLowerCase()) {
      case "recebido":
        return StatusRemessa.Recebido;
      case "confirmado":
        return StatusRemessa.Confirmado;
      case "coletado":
        return StatusRemessa.Coletado;
      case "em rota":
        return StatusRemessa.EmRota;
      case "entregue":
        return StatusRemessa.Entregue;
      default:
        print("State was $state");
        throw ArgumentError("O argumento informado não era esperado", "state");
    }
  }
}
