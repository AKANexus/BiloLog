import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/widgets/pacotes_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RemessaPacotesView extends StatefulWidget {
  const RemessaPacotesView({Key? key}) : super(key: key);
  static String routeName = '/listaRemessas/pacotesDaRemessa';

  @override
  State<RemessaPacotesView> createState() => _RemessaPacotesViewState();
}

class _RemessaPacotesViewState extends State<RemessaPacotesView> {
  @override
  Widget build(BuildContext context) {
    //final remessaAPI = Provider.of<RemessasAPI>(context);
    final operacaoRemessaProvider = Provider.of<OperacaoDeRemessaAPI>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacotes na Remessa"),
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
                  DateFormat.yMd()
                      .format(operacaoRemessaProvider.remessa!.dtRemessa),
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.grey),
                ),
                Text(
                    operacaoRemessaProvider.remessa!.nomeVendedor ??
                        "Múltiplos",
                    style: Theme.of(context).textTheme.headline5),
                Text(
                  "${operacaoRemessaProvider.remessa!.qtdPacotesProcessados} pacotes coletados",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //Text("Aguardando confirmação do cliente"),
                const Text("Lista de pacotes"),
              ],
            ),
          ),
          Expanded(
            child: RemessaPacotesList(operacaoRemessaProvider.pacotes),
          ),
        ]),
      ),
    );
  }
}
