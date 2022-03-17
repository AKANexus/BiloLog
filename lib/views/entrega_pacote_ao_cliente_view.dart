import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/status_pacote.dart';
import 'package:bilolog/providers/operacao_pacote_api.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/providers/remessas_api.dart';
import 'package:bilolog/views/pacotes_da_remessa_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: constant_identifier_names
enum TipoDoc { RG, CNH, CPF, CNPJ }

class EntregaPacoteView extends StatefulWidget {
  const EntregaPacoteView({Key? key}) : super(key: key);
  static const String routeName =
      "/listaRemessas/pacotesDaRemessa/entregaPacote";

  @override
  State<EntregaPacoteView> createState() => _EntregaPacoteViewState();
}

class _EntregaPacoteViewState extends State<EntregaPacoteView> {
  //bool _isInit = true;
  String selectedItem = "RG";
  bool _isBusy = false;
  late Pacote _pacote;

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {}
  //   super.didChangeDependencies();
  // }

  void _confirmarEntrega() async {
    //_pacote = pacote;
    setState(() {
      _isBusy = true;
    });
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    if (await operacaoPacoteProvider.entregaPacoteAoCliente(
            remessa: Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
                .remessa!,
            pacote: _pacote,
            nomeRecebedor:
                "$selectedItem${_recipientNameController.text.trim()}",
            documentoRecebedor: _recipientIDController.text,
            onError: (value) => {}) ==
        true) {
      final remessaAPI = Provider.of<RemessasAPI>(context, listen: false);
      final operacaoRemessa =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);

      await remessaAPI.getRemessas(onError: () {});
      operacaoRemessa.remessa = remessaAPI.remessas.firstWhere(
          (element) => element.uuid == operacaoRemessa.remessa!.uuid);

      _pacote.statusPacotes.add(StatusPacote(
          timestamp: DateTime.now(),
          funcionarioResponsavel: "",
          colaboradorId: "",
          descricaoStatus: "entregue"));
      Navigator.of(context).pushNamedAndRemoveUntil(
        RemessaPacotesView.routeName,
        ModalRoute.withName('/'),
      );
    }
    setState(() {
      _isBusy = false;
    });
  }

  bool _validaRGCPFCNPJCNH() {
    final entrada = _recipientIDController.text.trim();
    TipoDoc tipoDoc;
    switch (selectedItem) {
      case "RG":
        tipoDoc = TipoDoc.RG;
        break;
      case "CPF":
        tipoDoc = TipoDoc.CPF;
        break;
      case "CNPJ":
        tipoDoc = TipoDoc.CNPJ;
        break;
      default:
        return false;
    }
    if (tipoDoc == TipoDoc.RG) {
      var rgSemDV = entrada.substring(0, entrada.length - 1);
      var digitos = [];
      int tabela = 2;
      for (var item in rgSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
      }
      int verificacao = (11 - (digitos.reduce((a, b) => a + b) % 11)).round();
      if (verificacao == 10 &&
          entrada.substring(entrada.toLowerCase().length - 1) == 'x') {
        return true;
      } else if (verificacao ==
          int.parse(entrada.substring(entrada.length - 1))) {
        return true;
      } else {
        return false;
      }
    } else if (tipoDoc == TipoDoc.CPF) {
      var cpfSemDV = entrada.substring(0, entrada.length - 2);
      var digitos = [];
      int tabela = 1;
      for (var item in cpfSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
      }
      int modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cpfSemDV = "$cpfSemDV$modulo1";

      tabela = 0;
      digitos.clear();

      for (var item in cpfSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
      }
      modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cpfSemDV = "$cpfSemDV$modulo1";

      return (cpfSemDV == entrada);
    } else if (tipoDoc == TipoDoc.CNPJ) {
      var cpfSemDV = entrada.substring(0, entrada.length - 2);
      var digitos = [];
      int tabela = 6;
      for (var item in cpfSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
        if (tabela == 10) {
          tabela = 2;
        }
      }
      int modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cpfSemDV = "$cpfSemDV$modulo1";

      tabela = 5;
      digitos.clear();

      for (var item in cpfSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
        if (tabela == 10) {
          tabela = 2;
        }
      }
      modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cpfSemDV = "$cpfSemDV$modulo1";

      return (cpfSemDV == entrada);
    } else if (tipoDoc == TipoDoc.CNH) {
      return false;
    } else {
      return false;
    }
  }

  final _recipientNameController = TextEditingController();
  final _recipientIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    _pacote = operacaoPacoteProvider.pacote;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Trilhogística"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _pacote.cliente.nome,
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Entregando pacote...",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  "Digite os dados do recipiente para prosseguir",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: "Nome do Recipiente"),
                  controller: _recipientNameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  alignment: Alignment.centerLeft,
                  child: DropdownButton(
                      value: selectedItem,
                      items: <String>["RG", "CPF", "CNPJ"]
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedItem = value as String;
                        });
                      }),
                ),
                TextField(
                  //keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "$selectedItem do Recipiente"),
                  controller: _recipientIDController,
                ),
                const SizedBox(
                  height: 75,
                ),
                _isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.onPrimary),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {
                          if (!_validaRGCPFCNPJCNH()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "O $selectedItem não é válido. Tente novamente.")));
                          } else {
                            _confirmarEntrega();
                          }
                        },
                        child: const Text("Confirmar entrega"),
                      ),
              ],
            ),
          ),
        ));
  }
}
