import 'package:bilolog/widgets/coletasList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ColetasView extends StatelessWidget {
  ColetasView({Key? key}) : super(key: key);
  static const String routeName = "/coletasView";

  DateTime _filterDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.menu),
              itemBuilder: (_) {
                return [
                  const PopupMenuItem(child: Text("Opção 1")),
                  const PopupMenuItem(child: Text("Opção 2")),
                ];
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text("Minhas coletas",
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.left),
          TextField(
            decoration: InputDecoration(
              label: Text("Pesquisar"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Lista de coletas"),
              TextButton.icon(
                icon: Text(DateFormat('dd/MM/yyyy').format(_filterDate)),
                label: Icon(Icons.expand_more),
                onPressed: () {},
              )
            ],
          ),
          Expanded(
            child: ColetasList(),
          ),
        ]),
      ),
    );
  }
}
