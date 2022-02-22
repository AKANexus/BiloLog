import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bilolog/providers/novaColetaProvider.dart';
import 'package:bilolog/views/novaColetaCheckView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class QRScanView extends StatefulWidget {
  QRScanView({Key? key}) : super(key: key);

  static const String routeName = "/qrScanView";

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  String? _barcode;

  void _processQRCode(String barcode) {
    if (_barcode != barcode) {
      _barcode = barcode;
      print("QRCode detected>");
      print(barcode);
      Vibration.vibrate();
      final novaColetaProvider =
          Provider.of<NovaColetaProvider>(context, listen: false);
      final qrParsed = json.decode(barcode);
      novaColetaProvider.addNovaEntrega(qrParsed['id'], qrParsed['sender_id']);
    }
  }

  MobileScannerController controller =
      MobileScannerController(torchEnabled: false, facing: CameraFacing.back);

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      Provider.of<NovaColetaProvider>(context, listen: false).startNewColeta();
    }
    super.didChangeDependencies();
  }

  void conferirColeta() async {
    try {
      await Provider.of<NovaColetaProvider>(context, listen: false)
          .conferirColeta();
    } on Exception catch (e) {
      print("Falha ao conferirColeta()");
    }
    Navigator.of(context).pushNamed(NovaEntregaView.routeName);
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
                  _processQRCode(barcode.rawValue);
                },
                controller: controller,
                //fit: BoxFit.fitHeight,
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
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
          // Container(
          //   color: Colors.pink,
          //   child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         IconButton(
          //           color: Colors.white,
          //           icon: ValueListenableBuilder(
          //             valueListenable: controller.torchState,
          //             builder: (context, state, child) {
          //               switch (state as TorchState) {
          //                 case TorchState.off:
          //                   return const Icon(Icons.flash_off,
          //                       color: Colors.grey);
          //                 case TorchState.on:
          //                   return const Icon(Icons.flash_on,
          //                       color: Colors.yellow);
          //               }
          //             },
          //           ),
          //           iconSize: 32.0,
          //           onPressed: () => controller.toggleTorch(),
          //         ),
          //         Center(
          //           child: SizedBox(
          //             width: MediaQuery.of(context).size.width - 120,
          //             height: 50,
          //             child: FittedBox(
          //               child: Text(
          //                 _barcode ?? 'Scan something!',
          //                 overflow: TextOverflow.fade,
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .headline4!
          //                     .copyWith(color: Colors.white),
          //               ),
          //             ),
          //           ),
          //         ),
          //         IconButton(
          //           color: Colors.white,
          //           icon: ValueListenableBuilder(
          //             valueListenable: controller.cameraFacingState,
          //             builder: (context, state, child) {
          //               switch (state as CameraFacing) {
          //                 case CameraFacing.front:
          //                   return const Icon(Icons.camera_front);
          //                 case CameraFacing.back:
          //                   return const Icon(Icons.camera_rear);
          //               }
          //             },
          //           ),
          //           iconSize: 32.0,
          //           onPressed: () => controller.switchCamera(),
          //         ),
          //       ]),
          // ),
        ],
      ),
    );
  }
}
