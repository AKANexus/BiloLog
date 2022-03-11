enum RemessaKind { coleta, recebimento, entrega }

class RemessaKindConverter {
  static RemessaKind convert(String kind) {
    // StatusRemessa convertido;
    switch (kind) {
      case "operacaoColeta":
        return RemessaKind.coleta;
      default:
        // print("State was $state");
        throw ArgumentError("O argumento informado não era esperado", "kind");
    }
  }
}
