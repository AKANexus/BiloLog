import 'package:bilolog/models/remessa_type.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/remessa.dart';
import '../views/pacotes_da_remessa_view.dart';

class RemessaListTile extends StatelessWidget {
  const RemessaListTile(this._remessa, {Key? key}) : super(key: key);

  final Remessa _remessa;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final remessaProvider =
            Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
        remessaProvider.remessa = _remessa;
        Navigator.of(context).pushNamed(RemessaPacotesView.routeName);
      },
      child: Card(
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      DateFormat.yMd().format(_remessa.dtRemessa),
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        (_remessa.remessaKind == RemessaKind.coleta)
                            ? _remessa.nomeVendedor ?? "null"
                            : _remessa.nomeColaborador,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                        " ${_remessa.qtdPacotesProcessados} pacotes coletados"),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(_remessa.estadoRemessa['icon']),
                Text(_remessa.estadoRemessa['estado']),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
