import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bilolog/providers/novaColetaProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'novaColetaView.dart';

class ColetaQRScanView extends StatefulWidget {
  ColetaQRScanView({Key? key}) : super(key: key);

  static const String routeName = "/novaColeta";

  @override
  State<ColetaQRScanView> createState() => _ColetaQRScanViewState();
}

class _ColetaQRScanViewState extends State<ColetaQRScanView> {
  bool _isBusy = false;
  bool _isGrande = false;

  String? _barcode;
  MobileScannerController controller =
      MobileScannerController(torchEnabled: false, facing: CameraFacing.back);

  void _processQRCode(String barcode) {
    if (_barcode != barcode) {
      _barcode = barcode;
      print("QRCode detected>");
      print(barcode);
      Vibration.vibrate();
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
      final novaColetaProvider =
          Provider.of<NovaColetaProvider>(context, listen: false);
      final qrParsed = json.decode(barcode);
      novaColetaProvider.addNovoPacote(qrParsed['id'], qrParsed['sender_id'],
          _isGrande ? "grande" : "pequeno");
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      Provider.of<NovaColetaProvider>(context, listen: false).startNewColeta();
    }
    super.didChangeDependencies();
  }

  void _onError(String errorMessage) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  void conferirColeta() async {
    setState(() {
      _isBusy = true;
    });
    controller.stop();
    try {
      await Provider.of<NovaColetaProvider>(context, listen: false)
          .conferirColeta(_onError);
    } on Exception catch (e) {
      print("Falha ao conferirColeta()");
    }
    Navigator.of(context)
        .pushNamed(NovaColetaView.routeName)
        .then((value) => controller.start());
    setState(() {
      _isBusy = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 70,
          ),
          Text(
            "Escaneie os QR Codes",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "São aceitos apenas códigos do Mercado Envios Flex",
            textAlign: TextAlign.center,
          ),
          Container(
            margin: EdgeInsets.all(50),
            height: 300,
            width: 300,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.grey),
                  borderRadius: BorderRadius.circular(15)),
              child: MobileScanner(
                onDetect: (barcode, args) {
                  _processQRCode(barcode.rawValue ?? "");
                },
                controller: controller,
                //fit: BoxFit.fitHeight,
              ),
            ),
          ),
          SizedBox(
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
          SizedBox(
            height: 50,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: _isBusy
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      conferirColeta();
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
}
