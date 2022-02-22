import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/views/qrScanView.dart';
import 'package:bilolog/widgets/coletasList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/coleta.dart';
import '../widgets/appDrawer.dart';

class ColetasView extends StatefulWidget {
  //Stateful pois enquanto está em "loading", é exibido um _CircleLoading_, então muda o state da tela.
  ColetasView({Key? key}) : super(key: key);
  static const String routeName = "/coletasView";

  @override
  State<ColetasView> createState() => _ColetasViewState();
}

class _ColetasViewState extends State<ColetasView> {
  DateTime _filterDate = DateTime.now();

  List<Coleta>? _coletas;
  bool _isLoading = false;
  bool _isInit = true;

  Future<void> _getColetas(BuildContext context) async {
    //print("_getColetas called");
    setState(() {
      _isLoading = true;
    });
    final coletasProvider =
        Provider.of<ColetasProvider>(context, listen: false);
    await coletasProvider.getColetas();
    setState(() {
      _coletas = coletasProvider.coletas;
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getColetas(context);
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Trilhogística"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(QRScanView.routeName);
            },
            icon: Icon(Icons.add),
          ),
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
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _getColetas(context),
                    child: ColetasList(_coletas!)),
          ),
        ]),
      ),
    );
  }
}
