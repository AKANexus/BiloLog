import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pacotes_list_tile.dart';

class RemessaPacotesList extends StatelessWidget {
  const RemessaPacotesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entregasProvider =
        Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
    return ListView.builder(
      itemBuilder: (ctx, ix) {
        return PacotesListTile(entregasProvider.pacotes[ix]);
      },
      itemCount: entregasProvider.pacotes.length,
    );
  }
}
