import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/models/recebimento.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/coletaPacotesProvider.dart';
import 'package:bilolog/widgets/coletaPacotesList%20copy.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/recebimentoPacotesProvider.dart';
import '../widgets/coletaPacotesList.dart';

class RecebimentoPacotesView extends StatelessWidget {
  RecebimentoPacotesView({Key? key}) : super(key: key);
  static const String routeName = "/coletasView/pacotesView";

  late Recebimento _recebimento;

  @override
  Widget build(BuildContext context) {
    final entregasProvider = Provider.of<RecebimentoPacotesProvider>(context);
    _recebimento = entregasProvider.recebimento!;
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
                  DateFormat.yMd().format(_recebimento.dtColeta),
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey),
                ),
                Text(_recebimento.nomeVendedor,
                    style: Theme.of(context).textTheme.headline5),
                Text(
                  "${_recebimento.pacotesColetados} pacotes coletados",
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
            child: RecebimentoPacotesList(
                Provider.of<RecebimentoPacotesProvider>(context, listen: false)
                    .pacotes),
          ),
        ]),
      ),
    );
  }
}
