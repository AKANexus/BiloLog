import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:bilolog/providers/operacao_pacote_api.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/views/entrega_pacote_ao_cliente_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pacote.dart';
import '../views/pacote_detalhe_view.dart';

class PacotesListTile extends StatelessWidget {
  const PacotesListTile(this._pacote, {Key? key}) : super(key: key);

  final Pacote _pacote;

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Card(
      color: _pacote.hasError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (ctx, ctr) {
          if (ctr.maxWidth > 300) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _pacote.hasError
                      ? SizedBox(
                          height: 55.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Falha ao adicionar o pacote"),
                              Text(_pacote.errorMessage!)
                            ],
                          ),
                        )
                      : Row(
                          children: [
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
                                        const Icon(Icons.border_outer_rounded,
                                            size: 20),
                                        const SizedBox(
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
                                        const Icon(
                                            Icons.markunread_mailbox_outlined,
                                            size: 20),
                                        const SizedBox(
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
                                        const Icon(Icons.share, size: 20),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(_pacote.ultimoStatus),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _pacote.ultimoStatus != "Em rota" &&
                                    _pacote.ultimoStatus != "Entregue" &&
                                    authProvider.authorization !=
                                        Cargo.motocorno
                                ? TextButton(
                                    onPressed: () {
                                      final provider =
                                          Provider.of<OperacaoDeRemessaAPI>(
                                              context,
                                              listen: false);
                                      provider.pacote = _pacote;
                                      Navigator.of(context)
                                          .pushNamed(
                                              PacoteDetalheView.routeName)
                                          .then((_) {
                                        provider.pacote = null;
                                      });
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(Icons.qr_code),
                                        Text("Detalhes"),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                ),
                (_pacote.ultimoStatus == "Em rota" ||
                            _pacote.ultimoStatus == "Entregue") &&
                        authProvider.authorization == Cargo.motocorno
                    ? Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //THIS FUCKING THING REMOVES THE STUPID MARGIN AROUND THE BUTTONS. FFS
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                    ),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(0),
                                foregroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary),
                              ),
                              onPressed: () {
                                final provider =
                                    Provider.of<OperacaoDeRemessaAPI>(context,
                                        listen: false);
                                provider.pacote = _pacote;
                                Navigator.of(context)
                                    .pushNamed(PacoteDetalheView.routeName)
                                    .then((_) {
                                  provider.pacote = null;
                                });
                              },
                              child: const Text("Detalhes"),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //THIS FUCKING THING REMOVES THE STUPID MARGIN AROUND THE BUTTONS. FFS
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(0),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (_) => _pacote.ultimoStatus.toLowerCase() ==
                                          "em rota"
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onPrimary,
                                ),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (_) => _pacote.ultimoStatus.toLowerCase() ==
                                          "em rota"
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.green,
                                ),
                              ),
                              onPressed: _pacote.ultimoStatus.toLowerCase() ==
                                      "em rota"
                                  ? () {
                                      Provider.of<OperacaoDePacoteAPI>(context,
                                              listen: false)
                                          .pacote = _pacote;
                                      Navigator.of(context).pushNamed(
                                          EntregaPacoteView.routeName);
                                    }
                                  : null,
                              child: _pacote.ultimoStatus.toLowerCase() ==
                                      "em rota"
                                  ? Text("Entregar")
                                  : Text("Entregue"),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _pacote.hasError
                      ? SizedBox(
                          height: 55.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Falha ao adicionar o pacote",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_pacote.errorMessage!)
                            ],
                          ),
                        )
                      : Row(
                          children: [
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
                                        const Icon(Icons.border_outer_rounded,
                                            size: 20),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _pacote.codPacote.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.markunread_mailbox_outlined,
                                            size: 20),
                                        const SizedBox(
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
                                        const Icon(Icons.share, size: 20),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(_pacote.ultimoStatus),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [],
                            ),
                            _pacote.ultimoStatus != "Em rota" &&
                                    _pacote.ultimoStatus != "Entregue" &&
                                    authProvider.authorization !=
                                        Cargo.motocorno
                                ? TextButton(
                                    onPressed: () {
                                      final provider =
                                          Provider.of<OperacaoDeRemessaAPI>(
                                              context,
                                              listen: false);
                                      provider.pacote = _pacote;
                                      Navigator.of(context)
                                          .pushNamed(
                                              PacoteDetalheView.routeName)
                                          .then((_) {
                                        provider.pacote = null;
                                      });
                                    },
                                    child: Column(
                                      children: const [
                                        Icon(Icons.qr_code),
                                        Text("Detalhes"),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                ),
                (_pacote.ultimoStatus == "Em rota" ||
                            _pacote.ultimoStatus == "Entregue") &&
                        authProvider.authorization == Cargo.motocorno
                    ? Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //THIS FUCKING THING REMOVES THE STUPID MARGIN AROUND THE BUTTONS. FFS
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                    ),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(0),
                                foregroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary),
                              ),
                              onPressed: () {
                                final provider =
                                    Provider.of<OperacaoDeRemessaAPI>(context,
                                        listen: false);
                                provider.pacote = _pacote;
                                Navigator.of(context)
                                    .pushNamed(PacoteDetalheView.routeName)
                                    .then((_) {
                                  provider.pacote = null;
                                });
                              },
                              child: const Text("Detalhes"),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, //THIS FUCKING THING REMOVES THE STUPID MARGIN AROUND THE BUTTONS. FFS
                                shape: MaterialStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(0),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (_) => _pacote.ultimoStatus.toLowerCase() ==
                                          "em rota"
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onPrimary,
                                ),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (_) => _pacote.ultimoStatus.toLowerCase() ==
                                          "em rota"
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.green,
                                ),
                              ),
                              onPressed: _pacote.ultimoStatus.toLowerCase() ==
                                      "em rota"
                                  ? () {
                                      Provider.of<OperacaoDePacoteAPI>(context,
                                              listen: false)
                                          .pacote = _pacote;
                                      Navigator.of(context).pushNamed(
                                          EntregaPacoteView.routeName);
                                    }
                                  : null,
                              child: _pacote.ultimoStatus.toLowerCase() ==
                                      "em rota"
                                  ? Text("Entregar")
                                  : Text("Entregue"),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            );
          }
        },
      ),
    );
  }
}
