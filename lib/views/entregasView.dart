import 'package:flutter/material.dart';

import '../widgets/entregasList.dart';

class EntregasView extends StatelessWidget {
  const EntregasView({Key? key}) : super(key: key);
  static const String routeName = "/entregasView";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text("01/01/0001"),
          Text("Nome do cliente, bem grande!"),
          Text("45 pacotes coletados"),
          Text("Aguardando confirmação do cliente"),
          Text("Lista de entregas"),
          Expanded(
            child: EntregasList(),
          ),
        ]),
      ),
    );
  }
}
