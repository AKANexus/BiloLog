import 'package:flutter/material.dart';

import '../models/pacote.dart';
import '../views/pacote_detalhe_view.dart';

class PacotesListTile extends StatelessWidget {
  PacotesListTile(this._pacote, {Key? key}) : super(key: key);

  final Pacote _pacote;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _pacote.hasError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _pacote.hasError
            ? SizedBox(
                height: 55.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Falha ao adicionar o pacote"),
                    Text(_pacote.errorMessage!)
                  ],
                ),
              )
            : Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          _pacote.cliente.nome,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Icon(Icons.border_outer_rounded, size: 20),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              _pacote.codPacote.toString(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Icon(Icons.markunread_mailbox_outlined, size: 20),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${_pacote.cliente.cep.substring(0, 5)}-${_pacote.cliente.cep.substring(5)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(
                              width: 5,
                            ),
                            Text(_pacote.ultimoStatus),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // final entregasProvider =
                    //     Provider.of<EntregasProvider>(context, listen: false);
                    // entregasProvider.entrega = _entrega;
                    Navigator.of(context).pushNamed(PacoteDetalheView.routeName,
                        arguments: {'entrega': _pacote});
                  },
                  child: Column(
                    children: [
                      Icon(Icons.qr_code),
                      Text("Detalhes"),
                    ],
                  ),
                )
              ]),
      ),
    );
  }
}
