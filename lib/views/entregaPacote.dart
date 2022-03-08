import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/statusEntrega.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/entregaPacotesProvider.dart';
import '../providers/entregasProvider.dart';
import 'entregaPacotesView.dart';

class EntregaPacoteView extends StatefulWidget {
  const EntregaPacoteView({Key? key}) : super(key: key);
  static const String routeName = "/entregasView/pacotesView/entregarPacote";

  @override
  State<EntregaPacoteView> createState() => _EntregaPacoteViewState();
}

class _EntregaPacoteViewState extends State<EntregaPacoteView> {
  bool _isInit = true;
  late Pacote _pacote;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _pacote = args['pacote'];
    }
    super.didChangeDependencies();
  }

  void _confirmarEntrega() async {
    final entregasProvider =
        Provider.of<EntregasProvider>(context, listen: false);
    if (await entregasProvider.entregaPacoteAoCliente(
            _pacote, _recipientNameController.text, _recipientIDController.text,
            onError: (value) => {}) ==
        true) {
      entregasProvider.refreshCurrentEntregas((_) {});
      _pacote.statusPacotes.add(StatusPacote(
          timestamp: DateTime.now(),
          funcionarioResponsavel: "",
          colaboradorId: "",
          descricaoStatus: "entregue"));
      Navigator.of(context).pushNamedAndRemoveUntil(
        EntregaPacotesView.routeName,
        ModalRoute.withName('/'),
      );
    }
  }

  final _recipientNameController = TextEditingController();
  final _recipientIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Trilhogística"),
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
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Entregando pacote...",
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Digite os dados do recipiente para prosseguir",
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
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
                SizedBox(
                  height: 75,
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: _confirmarEntrega,
                  child: Text("Confirmar entrega"),
                ),
              ],
            ),
          ),
        ));
  }
}
