// ignore_for_file: prefer_const_constructors

import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/providers/remessas_api.dart';
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
  bool _showDialog = true;

  late String vendedorSelecionado;

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void _conferirEEnviar() async {
    setState(() {
      _isBusy = true;
    });
    final entregasProvider =
        Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
    if (entregasProvider.pacotes.any((element) => element.hasError)) {
      final proceed = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                    "Um ou mais pacotes não foram corretamente identificados e não serão coletados."),
                SizedBox(
                  height: 10,
                ),
                Text("Deseja prosseguir?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("SIM"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("NÃO"))
          ],
        ),
      );
      if (!proceed) {
        setState(() {
          _isBusy = false;
        });
        return;
      }
    }
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

  String get title {
    switch (Provider.of<AuthenticationProvider>(context, listen: false)
        .authorization) {
      case Cargo.invalid:
        return "ERRO";
      case Cargo.motocorno:
        return "Nova Entrega";
      case Cargo.coletor:
        return "Nova Coleta";
      case Cargo.galeraDoCD:
        return "Novo Recebimento";
      case Cargo.supervisor:
        return "Nova poha toda";
      case Cargo.administrador:
        return "Nova poha toda";
    }
  }

  @override
  Widget build(BuildContext context) {
    final operacaoRemessa =
        Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          Padding(
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
                        // Text(operacaoRemessa.vendedoresVerificados[0],
                        //     style: Theme.of(context).textTheme.headline5),
                        Text(
                          "${operacaoRemessa.pacotes.length} pacote(s) coletados",
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
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
                    Text("Lista de pacotes"),
                  ],
                ),
              ),
              Expanded(child: RemessaPacotesList(operacaoRemessa.pacotes)),
              _isBusy
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        _conferirEEnviar();
                      },
                      child: Text("Conferir e enviar"))
            ]),
          ),
          if (_showDialog &&
              operacaoRemessa.pacotes.any((element) => element.hasError))
            Container(
              color: Colors.black45,
            ),
          if (_showDialog &&
              operacaoRemessa.pacotes.any((element) => element.hasError))
            Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Card(
                    child: Container(
                  margin: EdgeInsets.all(15),
                  height: 250,
                  child: Column(
                    children: [
                      Text(
                        "Os pacotes a seguir estão inválidos e não poderão ser adicionados à remessa",
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (ctx, ix) => ListTile(
                            //title: Text(operacaoRemessa.pacotes[ix].id),
                            subtitle: Text(operacaoRemessa
                                    .pacotesComErro[ix].errorMessage ??
                                "Erro genérico"),
                            leading: Icon(Icons.error),
                          ),
                          itemCount: operacaoRemessa.pacotesComErro.length,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _showDialog = false;
                        }),
                        child: Text("ENTENDI"),
                      ),
                    ],
                  ),
                )),
              ),
            )
        ],
      ),
    );
  }
}
