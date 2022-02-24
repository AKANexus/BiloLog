import 'package:bilolog/models/coleta.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:bilolog/providers/novaColetaProvider.dart';
import 'package:bilolog/views/coletasView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/entregasList.dart';

class NovaColetaView extends StatefulWidget {
  NovaColetaView({Key? key}) : super(key: key);
  static const String routeName = "/novaColeta/checkColeta";

  @override
  State<NovaColetaView> createState() => _NovaColetaViewState();
}

class _NovaColetaViewState extends State<NovaColetaView> {
  late List<Coleta> _coletas;

  late String vendedorSelecionado;
  List<String> vendedoresVerificados = [];

  @override
  void initState() {
    final novaColetaProvider =
        Provider.of<NovaColetaProvider>(context, listen: false);
    vendedoresVerificados.clear();
    vendedoresVerificados = [...novaColetaProvider.SellerNames];
    vendedorSelecionado = vendedoresVerificados[0];
    super.initState();
  }

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
                            "${Provider.of<NovaColetaProvider>(context, listen: false).entregasPorSellerName(vendedorSelecionado).length} pacote(s) coletados",
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
                            "${Provider.of<NovaColetaProvider>(context, listen: false).entregasPorSellerName(vendedorSelecionado).length} pacote(s) coletados",
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
                Text("Lista de entregas"),
              ],
            ),
          ),
          Expanded(
              child: EntregasList(
            Provider.of<NovaColetaProvider>(context, listen: false)
                .entregasPorSellerName(vendedorSelecionado),
          )),
          ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<ColetasProvider>(context, listen: false)
                      .postNovaColetaJson(Provider.of<NovaColetaProvider>(
                              context,
                              listen: false)
                          .receivedJson);
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                } on Exception catch (e) {
                  print("erro ao check and send");
                }
              },
              child: Text("Conferir e enviar"))
        ]),
      ),
    );
  }
}
