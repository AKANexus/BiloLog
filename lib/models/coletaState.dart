enum ColetaState { Confirmado, Coletado, Recebido, EmRota, Entregue, EmAnalise }

class ColetaStateConverter {
  static ColetaState convert(String state) {
    ColetaState convertido;
    switch (state) {
      case "Recebido":
        return ColetaState.Recebido;
      case "Confirmado":
        return ColetaState.Confirmado;
      case "Coletado":
        return ColetaState.Coletado;
      case "Em rota":
        return ColetaState.EmRota;
      case "Entregue":
        return ColetaState.Entregue;
      default:
        throw ArgumentError("O argumento informado não era esperado", "state");
    }
  }
}
