import 'package:flutter/material.dart';

import '../models/remessa.dart';
import 'remessa_list_tile.dart';

class RemessasList extends StatelessWidget {
  final List<Remessa> remessas;

  const RemessasList({Key? key, required this.remessas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mqi = MediaQuery.of(context);
    return remessas.isEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: mqi.size.height - 270,
              child: const Center(
                child: Text("Nenhuma remessa encontrada"),
              ),
            ))
        : ListView.builder(
            itemBuilder: (ctx, ix) {
              return RemessaListTile(remessas[ix]);
            },
            itemCount: remessas.length,
          );
  }
}
