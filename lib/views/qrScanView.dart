import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QRScanView extends StatefulWidget {
  QRScanView({Key? key}) : super(key: key);

  static const String routeName = "/qrScanView";

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trilhogística"),
      ),
      body: Column(),
    );
  }
}
