import 'package:bilolog/main.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/views/entregasView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/coletasProvider.dart';

class ColetasList extends StatelessWidget {
  const ColetasList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coletasProvider = Provider.of<ColetasProvider>(context);
    final mqi = MediaQuery.of(context);
    return coletasProvider.coletas.length == 0
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
              return ColetasListTile(coletasProvider.coletas[ix]);
            },
            itemCount: coletasProvider.coletas.length,
          );
  }
}

class ColetasListTile extends StatelessWidget {
  const ColetasListTile(this.coleta, {Key? key}) : super(key: key);

  final Coleta coleta;

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
                      DateFormat.yMd().format(coleta.dtColeta),
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
                        coleta.nomeVendedor,
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
                        Text(" ${coleta.pacotesColetados} pacotes coletados"),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(coleta.estadoColeta['icon']),
                Text(coleta.estadoColeta['estado']),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
