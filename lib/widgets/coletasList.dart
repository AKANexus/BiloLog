import 'package:bilolog/main.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/views/entregasView.dart';
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
        return ColetasListTile(coletasProvider.coletas[ix]);
      },
      itemCount: coletasProvider.coletas.length,
    );
  }
}

class ColetasListTile extends StatelessWidget {
  const ColetasListTile(Coleta this.coleta, {Key? key}) : super(key: key);

  final coleta;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EntregasView.routeName);
      },
      child: Card(
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      "01/01/0001",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      "Nome do cliente bem grande",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text("120 pacotes coletados"),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(Icons.check),
                Text("confirmado"),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
