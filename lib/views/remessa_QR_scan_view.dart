import 'dart:convert';

import 'package:bilolog/providers/operacao_remessa_api.dart';
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
  MobileScannerController _controller =
      MobileScannerController(torchEnabled: false, facing: CameraFacing.back);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear QR Code"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 70,
          ),
          Text(
            "Escaneie os QR Codes",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "São aceitos apenas códigos do Mercado Envios Flex",
            textAlign: TextAlign.center,
          ),
          Container(
            margin: const EdgeInsets.all(50),
            height: 300,
            width: 300,
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
          const SizedBox(
            height: 50,
          ),
          Row(
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
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
      await Provider.of<OperacaoDeRemessaAPI>(context, listen: false)
          .conferirRemessa(onError: _onError);
    } on Exception {
      //print("Falha ao conferirColeta()");
    }
    Navigator.of(context)
        .pushNamed(NovaRemessaView.routeName)
        .then((value) => _controller.start());
    setState(() {
      _isBusy = false;
    });
  }

  void _processQRCode(String barcode) {
    if (_barcode != barcode) {
      _barcode = barcode;
      //print("QRCode detected>");
      //print(barcode);
      Vibration.vibrate();
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
      final novaColetaProvider =
          Provider.of<OperacaoDeRemessaAPI>(context, listen: false);
      final qrParsed = json.decode(barcode);
      novaColetaProvider.addNovoPacote(qrParsed['id'], qrParsed['sender_id'],
          _isGrande ? "grande" : "pequeno");
    }
  }
}
