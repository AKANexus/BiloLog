import 'package:bilolog/main.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/entregasProvider.dart';

class EntregasList extends StatelessWidget {
  const EntregasList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entregasProvider = Provider.of<EntregasProvider>(context);
    return ListView.builder(
      itemBuilder: (ctx, ix) {
        return EntregasListTile(entregasProvider.entregas[ix]);
      },
      itemCount: entregasProvider.entregas.length,
    );
  }
}

class EntregasListTile extends StatelessWidget {
  EntregasListTile(this.entrega, {Key? key}) : super(key: key);

  final entrega;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    "Washington Ferreira",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text("41096219893"),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    "Washington Ferreira",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text("41096219893"),
                )
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Column(
              children: [
                Icon(Icons.qr_code),
                Text("Detalhes"),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
