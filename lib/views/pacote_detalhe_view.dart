import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/pacote.dart';

class PacoteDetalheView extends StatelessWidget {
  const PacoteDetalheView({Key? key}) : super(key: key);
  static const String routeName =
      "/listaRemessas/pacotesDaRemessa/detalhesPacote";

  @override
  Widget build(BuildContext context) {
    final operacaoRemessaProvider = Provider.of<OperacaoDeRemessaAPI>(context);
    Pacote _pacote = operacaoRemessaProvider.pacoteDetalhe!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trilhogística"),
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
            const SizedBox(
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
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.add_box),
                            const SizedBox(width: 5),
                            Text(_pacote.codPacote.toString()),
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
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.share),
                            const SizedBox(width: 5),
                            Text(_pacote.ultimoStatus),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
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
                        const SizedBox(height: 5),
                        Text(
                          _pacote.vendedorName,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                    if (_pacote.id > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nº Coleta",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 5),
                          Text(_pacote.id.toString()),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              children: [
                Column(
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
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pacote.cliente.nome,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _pacote.cliente.endereco,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _pacote.cliente.bairro,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _pacote.cliente.cep,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        _pacote.cliente.complemento,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 25),
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
                              .format(_pacote.statusPacotes[ix].timestamp)),
                          const SizedBox(width: 15),
                          Text(
                            _pacote.statusPacotes[ix].descricaoStatus,
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Funcionário Responsável:"),
                          const SizedBox(width: 15),
                          Text(
                            _pacote.statusPacotes[ix].funcionarioResponsavel,
                          )
                        ],
                      ),
                      if (ix != _pacote.statusPacotes.length - 1)
                        const Divider()
                    ]),
                  ),
                  itemCount: _pacote.statusPacotes.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
