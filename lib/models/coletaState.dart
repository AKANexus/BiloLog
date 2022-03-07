enum ColetaState { Confirmado, Coletado, Recebido, EmRota, Entregue, EmAnalise }

class ColetaStateConverter {
  static ColetaState convert(String state) {
    ColetaState convertido;
    switch (state.toLowerCase()) {
      case "recebido":
        return ColetaState.Recebido;
      case "confirmado":
        return ColetaState.Confirmado;
      case "coletado":
        return ColetaState.Coletado;
      case "em rota":
        return ColetaState.EmRota;
      case "entregue":
        return ColetaState.Entregue;
      default:
        print("State was $state");
        throw ArgumentError("O argumento informado não era esperado", "state");
    }
  }
}
