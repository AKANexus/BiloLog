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

  final Entrega entrega;

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
                    entrega.cliente.nome,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Icon(Icons.border_outer_rounded, size: 20),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        entrega.codPacote.toString(),
                      ),
                    ],
                  ),
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
                  child: Row(
                    children: [
                      Icon(Icons.markunread_mailbox_outlined, size: 20),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "${entrega.cliente.cep.substring(0, 5)}-${entrega.cliente.cep.substring(5)}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(
                        width: 5,
                      ),
                      Text(entrega.ultimoStatus),
                    ],
                  ),
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
