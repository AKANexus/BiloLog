import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/entregasList.dart';

class EntregasView extends StatelessWidget {
  EntregasView({Key? key}) : super(key: key);
  static const String routeName = "/coletasView/entregasView";

  late Coleta _coleta;

  @override
  Widget build(BuildContext context) {
    final entregasProvider = Provider.of<EntregasProvider>(context);
    _coleta = entregasProvider.coleta!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat.yMd().format(_coleta.dtColeta),
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey),
                ),
                Text(_coleta.nomeVendedor,
                    style: Theme.of(context).textTheme.headline5),
                Text(
                  "{_coleta.pacotesColetados} pacotes coletados",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.grey,
                      ),
                ),
                SizedBox(
                  height: 20,
                ),
                //Text("Aguardando confirmação do cliente"),
                Text("Lista de entregas"),
              ],
            ),
          ),
          Expanded(
            child: EntregasList(),
          ),
        ]),
      ),
    );
  }
}
