import 'package:bilolog/providers/remessas_API.dart';
import 'package:bilolog/views/remessa_QR_scan_view.dart';
import 'package:bilolog/widgets/appDrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/remessa.dart';
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

  List<Remessa>? _remessas;
  bool _isBusy = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {}
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
              Navigator.of(context).pushNamed(RemessaQRScanView.routeName);
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
          const TextField(
            decoration: InputDecoration(
              label: Text("Pesquisar"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Lista de coletas"),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                icon: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                label: const Icon(Icons.expand_more),
                onPressed: () async {
                  final DateTime? _selectedDate;
                  _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (_selectedDate != null) {
                    setState(() {
                      _startDate = _selectedDate!;
                    });
                  }
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                icon: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                label: Icon(Icons.expand_more),
                onPressed: () async {
                  final DateTime? _selectedDate;
                  _selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (_selectedDate != null) {
                    setState(() {
                      _endDate = _selectedDate!;
                    });
                  }
                },
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
                    child: RemessasList()),
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
      _remessas = remessasProvider.remessas;
      _isBusy = false;
    });
  }

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}