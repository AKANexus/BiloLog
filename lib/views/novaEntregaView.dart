import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:bilolog/providers/novaEntregaProvider.dart';
import 'package:bilolog/views/entregasView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/coletaPacotesList.dart';

class NovaEntregaView extends StatefulWidget {
  NovaEntregaView({Key? key}) : super(key: key);
  static const String routeName = "/novaEntrega/checkEntrega";

  @override
  State<NovaEntregaView> createState() => _NovaEntregaViewState();
}

class _NovaEntregaViewState extends State<NovaEntregaView> {
  late List<Entrega> _entregas;

  late String vendedorSelecionado;
  List<String> vendedoresVerificados = [];

  @override
  void initState() {
    final novaEntregaProvider =
        Provider.of<NovaEntregaProvider>(context, listen: false);
    vendedoresVerificados.clear();
    vendedoresVerificados = [...novaEntregaProvider.SellerNames];
    vendedorSelecionado = vendedoresVerificados[0];
    super.initState();
  }

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void _conferirEEnviar() async {
    setState(() {
      _isBusy = true;
    });

    if (await Provider.of<EntregasProvider>(context, listen: false)
        .postNovaEntregaJson(
            Provider.of<NovaEntregaProvider>(context, listen: false)
                .receivedJson,
            onError: _onError)) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          EntregasView.routeName, ModalRoute.withName('/'));
    }

    setState(() {
      _isBusy = false;
    });
  }

  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    //final novaColetaProvider = Provider.of<NovaColetaProvider>(context);
    // _coletas = novaColetaProvider.coletasVerificadas;
    // vendedoresVerificados = novaColetaProvider.SellerNames;
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
                vendedoresVerificados.length == 1
                    ?
                    //Apenas um sender
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(vendedorSelecionado,
                              style: Theme.of(context).textTheme.headline5),
                          Text(
                            "${Provider.of<NovaEntregaProvider>(context, listen: false).pacotesPorSellerName(vendedorSelecionado).length} pacote(s) coletados",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      )
                    :
                    //Mais de um sender
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Escolha um vendedor:"),
                          DropdownButton<String>(
                              value: vendedorSelecionado,
                              items: vendedoresVerificados
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      child: Text(e),
                                      value: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  vendedorSelecionado = newValue!;
                                });
                              }),
                          Text(vendedorSelecionado,
                              style: Theme.of(context).textTheme.headline5),
                          Text(
                            "${Provider.of<NovaEntregaProvider>(context, listen: false).pacotesPorSellerName(vendedorSelecionado).length} pacote(s) coletados",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),

                SizedBox(
                  height: 20,
                ),
                //Text("Aguardando confirmação do cliente"),
                Text("Lista de pacotes a entregar"),
              ],
            ),
          ),
          Expanded(
              child: ColetaPacotesList(
            Provider.of<NovaEntregaProvider>(context, listen: false)
                .pacotesPorSellerName(vendedorSelecionado),
          )),
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
