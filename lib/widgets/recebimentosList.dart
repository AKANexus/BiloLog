import 'package:bilolog/main.dart';
import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/recebimento.dart';
import 'package:bilolog/providers/coletaPacotesProvider.dart';
import 'package:bilolog/views/coletaPacotesView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/coletasProvider.dart';
import '../providers/recebimentoPacotesProvider.dart';
import '../views/recebimentoPacotesView.dart';

class RecebimentosList extends StatelessWidget {
  RecebimentosList(List<Recebimento> this._recebimentos, {Key? key})
      : super(key: key);

  List<Recebimento> _recebimentos = [];

  @override
  Widget build(BuildContext context) {
    //final coletasProvider = Provider.of<ColetasProvider>(context);
    final mqi = MediaQuery.of(context);
    return _recebimentos.length == 0
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
              return RecebimentosListTile(_recebimentos[ix]);
            },
            itemCount: _recebimentos.length,
          );
  }
}

class RecebimentosListTile extends StatelessWidget {
  const RecebimentosListTile(this.recebimento, {Key? key}) : super(key: key);

  final Recebimento recebimento;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final entregasProvider =
            Provider.of<RecebimentoPacotesProvider>(context, listen: false);
        entregasProvider.recebimento = recebimento;
        Navigator.of(context).pushNamed(RecebimentoPacotesView.routeName);
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
                      DateFormat.yMd().format(recebimento.dtColeta),
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
                        recebimento.nomeVendedor,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                        " ${recebimento.pacotesColetados} pacotes coletados"),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(recebimento.estadoColeta['icon']),
                Text(recebimento.estadoColeta['estado']),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
