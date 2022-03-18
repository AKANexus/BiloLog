import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/widgets/manual_qr_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'nova_remessa_view.dart';

class RemessaQRScanView extends StatefulWidget {
  const RemessaQRScanView({Key? key}) : super(key: key);
  static const String routeName = "/novaRemessa";

  @override
  State<RemessaQRScanView> createState() => _RemessaQRScanViewState();
}

class _RemessaQRScanViewState extends State<RemessaQRScanView> {
  bool _isBusy = false;
  bool _isGrande = false;
  bool _isInit = true;

  String? _barcode;
  Map<String, dynamic>? _data;
  final _controller =
      MobileScannerController(torchEnabled: false, facing: CameraFacing.back);
  // final _audioPlayer = AudioPlayer();
  final _player = AudioCache(prefix: 'lib/assets/audio/');

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
          .startNewRemessa();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear QR Code"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10 * (deviceSize.height / 850.90),
          ),
          Text(
            "Escaneie os QR Codes",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 10 * (deviceSize.height / 850.90),
          ),
          const Text(
            "São aceitos apenas códigos do Mercado Envios Flex",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10 * (deviceSize.height / 850.90),
          ),
          SizedBox(
            height: 300 * (deviceSize.height / 850.90),
            width: 300 * (deviceSize.height / 850.90),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.grey),
                  borderRadius: BorderRadius.circular(15)),
              child: MobileScanner(
                onDetect: (barcode, args) {
                  _processQRCode(barcode.rawValue ?? "");
                },
                controller: _controller,
                //fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Center(
            child: TextButton(
                onPressed: () async {
                  _controller.stop();
                  final collectedInfo = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return const ManualQRDataEntry();
                    },
                  );
                  if (collectedInfo != null &&
                      collectedInfo['id'] != '' &&
                      int.tryParse(collectedInfo['sender_id']) != null) {
                    _processManualData(collectedInfo);
                  }
                  _controller.start();
                },
                child: const Text(
                  "Entrada manual",
                  style: TextStyle(fontSize: 18),
                )),
          ),
          SizedBox(
            height: 10 * (deviceSize.height / 850.90),
          ),
          Provider.of<AuthenticationProvider>(context, listen: false)
                      .authorization ==
                  Cargo.coletor
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pacote Pequeno",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Switch(
                            value: _isGrande,
                            onChanged: (value) {
                              setState(() {
                                _isGrande = value;
                              });
                            }),
                        Text(
                          "Pacote Grande",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: 50 * (deviceSize.height / 850.90),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: _isBusy
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      _conferirPacotes();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Conferir",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void _conferirPacotes() async {
    setState(() {
      _isBusy = true;
    });
    _controller.stop();
    try {
      final success =
          await Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
              .conferirRemessa(onError: _onError);
      if (success) {
        Navigator.of(context)
            .pushNamed(NovaRemessaView.routeName)
            .then((value) => _controller.start());
      } else {
        _controller.start();
      }
    } on Exception {
      //print("Falha ao conferirColeta()");
    }

    setState(() {
      _isBusy = false;
    });
  }

  void _processQRCode(String barcode) {
    if (_barcode != barcode) {
      _barcode = barcode;
      Vibration.vibrate();
      //FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
      _player.play("beep.wav");
      final novaColetaProvider =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
      final qrParsed = json.decode(barcode);
      novaColetaProvider.addNovoPacote(qrParsed['id'], qrParsed['sender_id'],
          _isGrande ? "grande" : "pequeno");
    }
  }

  void _processManualData(Map<String, dynamic> data) {
    if (_data != data) {
      _data = data;
      final novaColetaProvider =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
      novaColetaProvider.addNovoPacote(data['id'], int.parse(data['sender_id']),
          _isGrande ? "grande" : "pequeno");
    }
  }
}
