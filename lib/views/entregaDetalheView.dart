import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EntregaDetalheView extends StatelessWidget {
  EntregaDetalheView({Key? key}) : super(key: key);
  static const String routeName = "/entregaDetalheView";

  late Entrega _entrega;
  //late String _vendedorName;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _entrega = args['entrega'];
    //_vendedorName = args['vendedorName'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Informações do Pacote",
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              height: 35,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cod. pacote",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.add_box),
                            SizedBox(width: 5),
                            Text(_entrega.codPacote.toString()),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status atual",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 5),
                            Text(_entrega.ultimoStatus),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vendedor",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _entrega.vendedorName,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                    if (_entrega.id > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nº Coleta",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(height: 5),
                          Text(_entrega.id.toString()),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            Row(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Destinatário",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        "Endereço",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        "Bairro",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        "CEP",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Text(
                        "Complemento",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _entrega.cliente.nome,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _entrega.cliente.endereco,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _entrega.cliente.bairro,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _entrega.cliente.cep,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _entrega.cliente.complemento,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Divider(),
            SizedBox(height: 25),
            Text("Últimos status",
                style: Theme.of(context).textTheme.headline6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemBuilder: (ctx, ix) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Row(
                        children: [
                          Text(DateFormat.yMd()
                              .add_Hm()
                              .format(_entrega.statusEntregas[ix].timestamp)),
                          SizedBox(width: 15),
                          Text(
                            _entrega.statusEntregas[ix].descricaoStatus,
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Funcionário Responsável:"),
                          SizedBox(width: 15),
                          Text(
                            _entrega.statusEntregas[ix].funcionarioResponsavel,
                          )
                        ],
                      ),
                      if (ix != _entrega.statusEntregas.length - 1) Divider()
                    ]),
                  ),
                  itemCount: _entrega.statusEntregas.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
