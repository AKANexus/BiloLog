import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/views/ColetaQRScanView.dart';
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
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<Coleta>? _coletas;
  bool _isLoading = false;
  bool _isInit = true;

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _getColetas(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final coletasProvider =
        Provider.of<ColetasProvider>(context, listen: false);
    await coletasProvider.getColetas(_onError, _startDate, _endDate);
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
              Navigator.of(context).pushNamed(ColetaQRScanView.routeName);
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
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                icon: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                label: Icon(Icons.expand_more),
                onPressed: () async {
                  final _selectedDate;
                  _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  setState(() {
                    _startDate = _selectedDate;
                  });
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                icon: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                label: Icon(Icons.expand_more),
                onPressed: () async {
                  final _selectedDate;
                  _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  setState(() {
                    _endDate = _selectedDate;
                  });
                },
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
