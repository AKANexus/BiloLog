import 'dart:developer';
import 'dart:typed_data';

import 'package:bilolog/models/pacote.dart';
import 'package:bilolog/models/status_pacote.dart';
import 'package:bilolog/providers/location_provider.dart';
import 'package:bilolog/providers/operacao_pacote_api.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/providers/remessas_api.dart';
import 'package:bilolog/views/pacotes_da_remessa_view.dart';
import 'package:bilolog/widgets/observacao_pacote_entry.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: constant_identifier_names
enum TipoDoc { RG, CNH, CPF, CNPJ, NaoPresencial }

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
  final location = LocationProvider();
  Map<String, dynamic> dados = {};

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void _naoEntrega() async {
    setState(() {
      _isBusy = true;
    });
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    if (await operacaoPacoteProvider.problemaAoEntregarPacote(
            remessa: Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
                .remessa!,
            pacote: _pacote,
            dados: dados,
            latitude: (await location.getCurrentLocation()).latitude ?? 0,
            longitude: (await location.getCurrentLocation()).longitude ?? 0,
            onError: (value) => {}) ==
        true) {
      final remessaAPI = Provider.of<RemessasAPI>(context, listen: false);
      final operacaoRemessa =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);

      // await remessaAPI.getRemessas(onError: _onError);
      // operacaoRemessa.remessa = remessaAPI.remessas.firstWhere(
      //     (element) => element.uuid == operacaoRemessa.remessa!.uuid);

      operacaoRemessa.atualizaStatusPacote(
          _pacote,
          StatusPacote(
              timestamp: DateTime.now(),
              funcionarioResponsavel: "",
              colaboradorId: "",
              descricaoStatus: "pendente"));
      Navigator.of(context).pushNamedAndRemoveUntil(
        RemessaPacotesView.routeName,
        ModalRoute.withName('/'),
      );
    }
    setState(() {
      _isBusy = false;
    });
  }

  void _confirmarEntrega() async {
    setState(() {
      _isBusy = true;
    });
    final operacaoPacoteProvider =
        Provider.of<OperacaoDePacoteAPI>(context, listen: false);
    if (await operacaoPacoteProvider.entregaPacoteAoClienteMP(
            remessa: Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
                .remessa!,
            pacote: _pacote,
            dados: dados,
            latitude: (await location.getCurrentLocation()).latitude ?? 0,
            longitude: (await location.getCurrentLocation()).longitude ?? 0,
            nomeRecebedor: "${_recipientNameController.text.trim()}",
            documentoRecebedor: "$selectedItem:${_recipientIDController.text}",
            onError: _onError) ==
        true) {
      final remessaAPI = Provider.of<RemessasAPI>(context, listen: false);
      final operacaoRemessa =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
      // await remessaAPI.getRemessas(onError: () {});
      // operacaoRemessa.remessa = remessaAPI.remessas.firstWhere(
      //     (element) => element.uuid == operacaoRemessa.remessa!.uuid);
      operacaoRemessa.atualizaStatusPacote(
          _pacote,
          StatusPacote(
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

  Future<Map<String, dynamic>> _validaRGCPFCNPJCNH() async {
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
      case "Não Presencial":
        tipoDoc = TipoDoc.NaoPresencial;
        break;
      default:
        return {'check': false, 'motive': 'DEFAULT'};
    }
    if (tipoDoc == TipoDoc.RG) {
      return entrada.length <= 5
          ? {'check': false, 'motive': 'RG_TOO_SHORT'}
          : {'check': true};
      var rgSemDV = entrada.substring(0, entrada.length - 1);
      var digitos = [];
      int tabela = 2;
      for (var item in rgSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
      }
      int verificacao = (11 - (digitos.reduce((a, b) => a + b) % 11)).round();
      if (verificacao == 10 &&
          entrada.substring(entrada.toLowerCase().length - 1) == 'x') {
        return {'check': true};
      } else if (verificacao ==
          int.parse(entrada.substring(entrada.length - 1))) {
        return {'check': true};
      } else {
        return {'check': false, 'motive': 'INVALID_RG'};
      }
    } else if (tipoDoc == TipoDoc.CPF) {
      if (entrada.length != 11) {
        return {'check': false, 'motive': 'INVALID_CPF'};
      }
      var cpfSemDV = entrada.substring(0, entrada.length - 2);
      if ({...cpfSemDV.characters}.length == 1) {
        return {'check': false, 'motive': 'INVALID_CPF'};
      }
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
      return (cpfSemDV == entrada)
          ? {'check': true}
          : {'check': false, 'motive': 'INVALID_CPF'};
    } else if (tipoDoc == TipoDoc.CNPJ) {
      if (entrada.length != 14) {
        return {'check': false, 'motive': 'INVALID_CPF'};
      }
      var cnpjSemDV = entrada.substring(0, entrada.length - 2);
      if ({...cnpjSemDV.characters}.length == 1) {
        return {'check': false, 'motive': 'INVALID_CNPJ'};
      }
      var digitos = [];
      int tabela = 6;
      for (var item in cnpjSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
        if (tabela == 10) {
          tabela = 2;
        }
      }
      int modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cnpjSemDV = "$cnpjSemDV$modulo1";

      tabela = 5;
      digitos.clear();

      for (var item in cnpjSemDV.characters) {
        digitos.add(int.parse(item) * tabela++);
        if (tabela == 10) {
          tabela = 2;
        }
      }
      modulo1 = (digitos.reduce((a, b) => a + b) % 11).round();
      if (modulo1 == 10) {
        modulo1 == 0;
      }
      cnpjSemDV = "$cnpjSemDV$modulo1";

      return (cnpjSemDV == entrada)
          ? {'check': true}
          : {'check': false, 'motive': 'INVALID_CNPJ'};
    } else if (tipoDoc == TipoDoc.CNH) {
      return {'check': false, 'motive': 'CNH_NOT_ACCEPTED'};
    } else if (tipoDoc == TipoDoc.NaoPresencial) {
      _recipientIDController.text = "Não presencial";
      {
        final collectedInfo = await showModalBottomSheet(
          isDismissible: false,
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return ObservacaoPacoteEntry();
          },
        );
        if (collectedInfo == null) {
          return {'check': false, 'motive': 'NO_DATA_COLLECTED'};
        }
        if (collectedInfo['images'] == null ||
            (collectedInfo['images'] as List<XFile>).isEmpty) {
          return {'check': false, 'motive': 'NO_IMAGES_ADDED'};
        }
        dados = collectedInfo;
        return {'check': true};
      }
    } else {
      return {'check': false, 'motive': 'WRONG_TIPO_DOC'};
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: (selectedItem == "Não Presencial"),
                        decoration: InputDecoration(
                            labelText: (selectedItem == "Não Presencial")
                                ? "Não Presencial"
                                : "Nome do Recipiente"),
                        controller: _recipientNameController,
                      ),
                    ),
                    TextButton(
                      child: const Text("Copiar"),
                      onPressed: (selectedItem != "Não Presencial")
                          ? () {
                              _recipientNameController.text =
                                  _pacote.cliente.nome;
                            }
                          : null,
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 5),
                  alignment: Alignment.centerLeft,
                  child: DropdownButton(
                      value: selectedItem,
                      items: <String>["RG", "CPF", "CNPJ", "Não Presencial"]
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _recipientIDController.text = "";
                          if (value == "Não Presencial") {
                            _recipientNameController.text = "Não Presencial";
                          }
                          selectedItem = value as String;
                        });
                      }),
                ),
                TextField(
                  readOnly: (selectedItem == "Não Presencial"),
                  decoration: InputDecoration(
                      labelText: (selectedItem == "Não Presencial")
                          ? "Não Presencial"
                          : "$selectedItem do Recipiente"),
                  controller: _recipientIDController,
                ),
                const SizedBox(
                  height: 75,
                ),
                _isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.onPrimary),
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            onPressed: () async {
                              if (_recipientNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Digite um nome válido."),
                                  ),
                                );
                                return;
                              }
                              final validation = await _validaRGCPFCNPJCNH();
                              if (validation['check']) {
                                _confirmarEntrega();
                                return;
                              } else {
                                switch (validation['motive']) {
                                  case 'RG_TOO_SHORT':
                                  case 'INVALID_RG':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("RG inválido."),
                                      ),
                                    );
                                    return;
                                  case 'INVALID_CPF':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("CPF inválido."),
                                      ),
                                    );
                                    return;
                                  case 'INVALID_CNPJ':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("CNPJ inválido."),
                                      ),
                                    );
                                    return;
                                  case 'NO_DATA_COLLECTED':
                                    return;
                                  case 'NO_IMAGES_ADDED':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Adicione pelo menos uma foto."),
                                      ),
                                    );
                                    return;
                                  case 'DEFAULT':
                                  default:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Erro desconhecido."),
                                      ),
                                    );
                                    return;
                                }
                              }
                            },
                            child: const Text("Confirmar entrega"),
                          ),
                          TextButton(
                            child: const Text("Não consegui entregar"),
                            onPressed: () async {
                              final collectedInfo = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) {
                                  return ObservacaoPacoteEntry();
                                },
                              );
                              if (collectedInfo == null) {
                                return;
                              }
                              if (collectedInfo['images'] == null ||
                                  (collectedInfo['images'] as List<XFile>)
                                      .isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Adicione pelo menos uma foto."),
                                  ),
                                );
                                return;
                              }
                              dados = collectedInfo;
                              return _naoEntrega();
                            },
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ));
  }
}
