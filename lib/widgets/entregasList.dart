import 'package:bilolog/main.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/providers/entregaPacotesProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/coletasProvider.dart';
import '../views/entregaPacotesView.dart';

class EntregasList extends StatelessWidget {
  EntregasList(List<Entrega> this._entregas, {Key? key}) : super(key: key);

  List<Entrega> _entregas = [];

  @override
  Widget build(BuildContext context) {
    final mqi = MediaQuery.of(context);
    return _entregas.length == 0
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: mqi.size.height - 270,
              child: Center(
                child: Text("Nenhuma coleta recebida"),
              ),
            ),
          )
        : ListView.builder(
            itemBuilder: (ctx, ix) {
              return EntregasListTile(_entregas[ix]);
            },
            itemCount: _entregas.length,
          );
  }
}

class EntregasListTile extends StatelessWidget {
  const EntregasListTile(this.entrega, {Key? key}) : super(key: key);

  final Entrega entrega;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final entregasProvider =
            Provider.of<EntregaPacotesProvider>(context, listen: false);
        entregasProvider.entrega = entrega;
        Navigator.of(context).pushNamed(EntregaPacotesView.routeName);
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
                      DateFormat.yMd().format(entrega.dtColeta),
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        entrega.nomeVendedor,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child:
                        Text(" ${entrega.pacotesAEntregar} pacotes coletados"),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(entrega.estadoColeta['icon']),
                Text(entrega.estadoColeta['estado']),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
