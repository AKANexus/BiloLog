import 'package:bilolog/models/coleta.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/coletasProvider.dart';

class ColetasList extends StatelessWidget {
  const ColetasList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coletasProvider = Provider.of<ColetasProvider>(context);
    return ListView.builder(
      itemBuilder: (ctx, ix) {
        return ColetasListTile(coletasProvider.coletasTeste[ix]);
      },
      itemCount: coletasProvider.coletasTeste.length,
    );
  }
}

class ColetasListTile extends StatelessWidget {
  const ColetasListTile(Coleta this.coleta, {Key? key}) : super(key: key);

  final coleta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(children: [
        Column(
          children: [
            Text("01/01/0001"),
            Text("Nome do cliente bem grande"),
            Text("120 pacotes coletados")
          ],
        ),
        Column(
          children: [
            Icon(Icons.check),
            Text("confirmado"),
          ],
        )
      ]),
    );
  }
}
