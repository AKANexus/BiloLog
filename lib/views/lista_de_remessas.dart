// ignore_for_file: prefer_const_constructors

import 'package:bilolog/providers/auth_provider.dart';
import 'package:bilolog/providers/location_provider.dart';
import 'package:bilolog/providers/remessas_api.dart';
import 'package:bilolog/views/remessa_qr_scan_view.dart';
import 'package:bilolog/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../models/cargo.dart';
import '../widgets/remessas_list.dart';

class RemessasView extends StatefulWidget {
  const RemessasView({Key? key}) : super(key: key);
  static const String routeName = "/listaRemessas";

  @override
  State<RemessasView> createState() => _RemessasViewState();
}

class _RemessasViewState extends State<RemessasView> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isBusy = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getRemessas(context);
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  String get title {
    switch (Provider.of<AuthenticationProvider>(context, listen: false)
        .authorization) {
      case Cargo.invalid:
        return "ERRO";
      case Cargo.motocorno:
        return "Entregas";
      case Cargo.coletor:
        return "Coletas";
      case Cargo.galeraDoCD:
        return "Recebimentos";
      case Cargo.supervisor:
        return "A poha toda";
    }
  }

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    // print("Rebuilt");
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RemessaQRScanView.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: title == "A poha toda"
          ? Center(child: Text("Acesso negado"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        "Minhas remessas (${Provider.of<RemessasAPI>(context).remessas.fold(0, (int sum, x) => sum + x.qtdPacotesProcessados)})",
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.left),
                    // const TextField(
                    //   decoration: InputDecoration(
                    //     label: Text("Pesquisar"),
                    //   ),
                    // ),
                    // Text("Lista de remessas"),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          icon:
                              Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                          label: const Icon(Icons.expand_more),
                          onPressed: !_isBusy
                              ? () async {
                                  final DateTime? _selectedDate;
                                  _selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now());
                                  if (_selectedDate != null) {
                                    setState(() {
                                      _startDate = _selectedDate!;
                                      _getRemessas(context);
                                    });
                                  }
                                }
                              : null,
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          icon: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                          label: Icon(Icons.expand_more),
                          onPressed: !_isBusy
                              ? () async {
                                  final DateTime? _selectedDate;
                                  _selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now());
                                  if (_selectedDate != null) {
                                    setState(() {
                                      _endDate = _selectedDate!;
                                      _getRemessas(context);
                                    });
                                  }
                                }
                              : null,
                        )
                      ],
                    ),
                    Expanded(
                      child: _isBusy
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _getRemessas(context),
                              child: RemessasList(
                                remessas:
                                    Provider.of<RemessasAPI>(context).remessas,
                              )),
                    ),
                  ]),
            ),
    );
  }

  Future<void> _getRemessas(BuildContext context) async {
    setState(() {
      _isBusy = true;
    });
    final remessasProvider = Provider.of<RemessasAPI>(context, listen: false);
    await remessasProvider.getRemessas(
        onError: _onError, startDate: _startDate, endDate: _endDate);
    setState(() {
      _isBusy = false;
    });
  }

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
