import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/status_pacote.dart';
import 'package:bilolog/providers/operacao_pacote_api.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/providers/remessas_api.dart';
import 'package:bilolog/views/pacotes_da_remessa_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntregaPacoteView extends StatefulWidget {
  const EntregaPacoteView({Key? key}) : super(key: key);
  static const String routeName =
      "/listaRemessas/pacotesDaRemessa/entregaPacote";

  @override
  State<EntregaPacoteView> createState() => _EntregaPacoteViewState();
}

class _EntregaPacoteViewState extends State<EntregaPacoteView> {
  //bool _isInit = true;
  late Pacote _pacote;

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {}
  //   super.didChangeDependencies();
  // }

  void _confirmarEntrega() async {
    //_pacote = pacote;
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    if (await operacaoPacoteProvider.entregaPacoteAoCliente(
            remessa: Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
                .remessa!,
            pacote: _pacote,
            nomeRecebedor: _recipientNameController.text,
            documentoRecebedor: _recipientIDController.text,
            onError: (value) => {}) ==
        true) {
      final remessaAPI = Provider.of<RemessasAPI>(context, listen: false);
      final operacaoRemessa =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);

      await remessaAPI.getRemessas(onError: () {});
      operacaoRemessa.remessa = remessaAPI.remessas.firstWhere(
          (element) => element.uuid == operacaoRemessa.remessa!.uuid);

      _pacote.statusPacotes.add(StatusPacote(
          timestamp: DateTime.now(),
          funcionarioResponsavel: "",
          colaboradorId: "",
          descricaoStatus: "entregue"));
      Navigator.of(context).pushNamedAndRemoveUntil(
        RemessaPacotesView.routeName,
        ModalRoute.withName('/'),
      );
    }
  }

  final _recipientNameController = TextEditingController();
  final _recipientIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    _pacote = operacaoPacoteProvider.pacote;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Trilhogística"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _pacote.cliente.nome,
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Entregando pacote...",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "Digite os dados do recipiente para prosseguir",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: "Nome do Recipiente"),
                  controller: _recipientNameController,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Documento do Recipiente"),
                  controller: _recipientIDController,
                ),
                const SizedBox(
                  height: 75,
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    _confirmarEntrega();
                  },
                  child: const Text("Confirmar entrega"),
                ),
              ],
            ),
          ),
        ));
  }
}
