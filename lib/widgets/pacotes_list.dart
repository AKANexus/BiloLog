import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pacotes_list_tile.dart';

class RemessaPacotesList extends StatelessWidget {
  const RemessaPacotesList(this._pacotes, {Key? key}) : super(key: key);

  final List<Pacote> _pacotes;

  @override
  Widget build(BuildContext context) {
    //final entregasProvider = Provider.of<OperacaoDeRemessaAPI>(context);
    return ListView.builder(
      itemBuilder: (ctx, ix) {
        return PacotesListTile(_pacotes[ix]);
      },
      itemCount: _pacotes.length,
    );
  }
}
