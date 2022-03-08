import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/coletaPacotesProvider.dart';
import 'package:bilolog/providers/entregaPacotesProvider.dart';
import 'package:bilolog/widgets/entregaPacotesList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/coletaPacotesList.dart';

class EntregaPacotesView extends StatefulWidget {
  EntregaPacotesView({Key? key}) : super(key: key);
  static const String routeName = "/entregasView/pacotesView";

  @override
  State<EntregaPacotesView> createState() => _EntregaPacotesViewState();
}

class _EntregaPacotesViewState extends State<EntregaPacotesView> {
  late Entrega _entrega;

  @override
  Widget build(BuildContext context) {
    final entregasProvider = Provider.of<EntregaPacotesProvider>(context);
    _entrega = entregasProvider.entrega!;
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
                  DateFormat.yMd().format(_entrega.dtColeta),
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey),
                ),
                Text(_entrega.nomeVendedor,
                    style: Theme.of(context).textTheme.headline5),
                Text(
                  "${_entrega.pacotesAEntregar} pacotes a entregar",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.grey,
                      ),
                ),
                SizedBox(
                  height: 20,
                ),
                //Text("Aguardando confirmação do cliente"),
                Text("Lista de pacotes"),
              ],
            ),
          ),
          Expanded(
            child: EntregaPacotesList(
                Provider.of<EntregaPacotesProvider>(context).pacotes),
          ),
        ]),
      ),
    );
  }
}
