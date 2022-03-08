enum RemessaState {
  Confirmado,
  Coletado,
  Recebido,
  EmRota,
  Entregue,
  EmAnalise
}

class ColetaStateConverter {
  static RemessaState convert(String state) {
    RemessaState convertido;
    switch (state.toLowerCase()) {
      case "recebido":
        return RemessaState.Recebido;
      case "confirmado":
        return RemessaState.Confirmado;
      case "coletado":
        return RemessaState.Coletado;
      case "em rota":
        return RemessaState.EmRota;
      case "entregue":
        return RemessaState.Entregue;
      default:
        print("State was $state");
        throw ArgumentError("O argumento informado não era esperado", "state");
    }
  }
}
