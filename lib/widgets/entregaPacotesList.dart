import 'package:bilolog/main.dart';
import 'package:bilolog/models/entrega.dart';
import 'package:bilolog/models/pacote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/coletaPacotesProvider.dart';
import '../views/ColetaPacoteDetalheView.dart';
import '../views/entregaPacote.dart';

class EntregaPacotesList extends StatelessWidget {
  const EntregaPacotesList(this._entregas, {Key? key}) : super(key: key);

  final List<Pacote> _entregas;

  @override
  Widget build(BuildContext context) {
    //final entregasProvider = Provider.of<EntregasProvider>(context);
    return ListView.builder(
      itemBuilder: (ctx, ix) {
        return PacotesEntregaListTile(_entregas[ix]);
      },
      itemCount: _entregas.length,
    );
  }
}

class PacotesEntregaListTile extends StatelessWidget {
  PacotesEntregaListTile(this._pacote, {Key? key}) : super(key: key);

  final Pacote _pacote;

  Color getColor(Set<MaterialState> states, BuildContext context) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    return Theme.of(context).colorScheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(children: [
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
                ]),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, //THIS FUCKING THING REMOVES THE STUPID MARGIN AROUND THE BUTTONS. FFS
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
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
                    Navigator.of(context).pushNamed(
                        ColetaPacoteDetalheView.routeName,
                        arguments: {'entrega': _pacote});
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
                    foregroundColor: MaterialStateProperty.resolveWith(
                      (_) => _pacote.ultimoStatus.toLowerCase() == "em rota"
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith(
                      (_) => _pacote.ultimoStatus.toLowerCase() == "em rota"
                          ? Theme.of(context).colorScheme.primary
                          : Colors.green,
                    ),
                  ),
                  onPressed: () {
                    _pacote.ultimoStatus.toLowerCase() == "em rota"
                        ? Navigator.of(context).pushNamed(
                            EntregaPacoteView.routeName,
                            arguments: {'pacote': _pacote})
                        : null;
                  },
                  child: _pacote.ultimoStatus.toLowerCase() == "em rota"
                      ? Text("Entregar")
                      : Text("Entregue"),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
