import 'package:flutter/material.dart';

import '../models/remessa.dart';
import 'remessa_list_tile.dart';

class RemessasList extends StatefulWidget {
  const RemessasList({Key? key}) : super(key: key);

  @override
  State<RemessasList> createState() => _RemessasListState();
}

class _RemessasListState extends State<RemessasList> {
  List<Remessa> _remessas = [];

  @override
  Widget build(BuildContext context) {
    final mqi = MediaQuery.of(context);
    return _remessas.isEmpty
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              height: mqi.size.height - 270,
              child: Center(
                child: Text("Nenhuma remessa encontrada"),
              ),
            ))
        : ListView.builder(
            itemBuilder: (ctx, ix) {
              return RemessaListTile(_remessas[ix]);
            },
            itemCount: _remessas.length,
          );
  }
}
