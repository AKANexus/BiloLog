import 'package:bilolog/providers/operacao_remessa_API.dart';
import 'package:bilolog/providers/remessas_API.dart';
import 'package:bilolog/views/lista_de_remessas.dart';
import 'package:bilolog/widgets/pacotes_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NovaRemessaView extends StatefulWidget {
  const NovaRemessaView({Key? key}) : super(key: key);
  static const String routeName = "/novaRemessa/checkRemessa";

  @override
  State<NovaRemessaView> createState() => _NovaRemessaViewState();
}

class _NovaRemessaViewState extends State<NovaRemessaView> {
  bool _isBusy = false;
  late String vendedorSelecionado;

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void _conferirEEnviar() async {
    setState(() {
      _isBusy = true;
    });

    if (await Provider.of<RemessasAPI>(context, listen: false)
        .postNovaRemessaJson(
            jsonBody: Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
                .jsonRetornado!,
            onError: _onError)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          RemessasView.routeName, ModalRoute.withName('/'));
    }

    setState(() {
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final operacaoRemessa = Provider.of<OperacaoDeRemessaAPI>(context);
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(vendedorSelecionado,
                        style: Theme.of(context).textTheme.headline5),
                    Text(
                      "${operacaoRemessa.pacotes.length} pacote(s) coletados",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                //Mais de um sender
                SizedBox(
                  height: 20,
                ),
                //Text("Aguardando confirmação do cliente"),
                Text("Lista de entregas"),
              ],
            ),
          ),
          Expanded(child: RemessaPacotesList()),
          _isBusy
              ? Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () {
                    _conferirEEnviar();
                  },
                  child: Text("Conferir e enviar"))
        ]),
      ),
    );
  }
}
