import 'package:bilolog/providers/entregasProvider.dart';
import 'package:bilolog/views/EntregaQRScanView.dart';
import 'package:bilolog/widgets/entregasList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/entrega.dart';
import '../models/pacote.dart';
import '../widgets/appDrawer.dart';

class EntregasView extends StatefulWidget {
  //Stateful pois enquanto está em "loading", é exibido um _CircleLoading_, então muda o state da tela.
  EntregasView({Key? key}) : super(key: key);
  static const String routeName = "/entregasView";

  @override
  State<EntregasView> createState() => _EntregasViewState();
}

class _EntregasViewState extends State<EntregasView> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<Pacote>? _entregas;
  bool _isLoading = false;
  bool _isInit = true;

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _getEntregas(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    // final entregasProvider =
    //     Provider.of<EntregasProvider>(context, listen: false);
    // await entregasProvider.getEntregas(_onError, _startDate, _endDate);
    // setState(() {
    //   _entregas = entregasProvider.pacotes;
    //   _isLoading = false;
    // });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getEntregas(context);
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
              Navigator.of(context).pushNamed(EntregaQRScanView.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text("Minhas entregas",
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
              Text("Lista de entregas"),
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
                    onRefresh: () => _getEntregas(context),
                    child: EntregasList(_entregas!)),
          ),
        ]),
      ),
    );
  }
}
