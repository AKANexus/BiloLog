import 'dart:io';

import 'package:bilolog/providers/authProvider.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:bilolog/providers/novaColetaProvider.dart';
import 'package:bilolog/views/authView.dart';
import 'package:bilolog/views/coletasView.dart';
import 'package:bilolog/views/entregaDetalheView.dart';
import 'package:bilolog/views/entregasView.dart';
import 'package:bilolog/views/qrScanView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/novaColetaView.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

//TODO: REMOVE BEFORE PRODUCTION!!!!!
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
//TODO: REMOVE BEFORE PRODUCTION!!!!!

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProxyProvider<AuthenticationProvider, NovaColetaProvider>(
            create: (_) => NovaColetaProvider(),
            update: (_, auth, previousProvider) => previousProvider!
              ..authInfo = {'apiKey': auth.apiKey, 'uuid': auth.uuid}),
        ChangeNotifierProxyProvider<AuthenticationProvider, ColetasProvider>(
            create: (_) => ColetasProvider(),
            update: (_, auth, previousProvider) =>
                previousProvider!..apiKey = auth.apiKey),
        ChangeNotifierProvider(create: (_) => EntregasProvider()),
      ],
      child: MaterialApp(
        title: 'Bilolog',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthenticationProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? ColetasView() : AuthenticationView();
          },
        ),
        routes: {
          ColetasView.routeName: (ctx) => ColetasView(),
          EntregasView.routeName: (ctx) => EntregasView(),
          EntregaDetalheView.routeName: (ctx) => EntregaDetalheView(),
          QRScanView.routeName: (ctx) => QRScanView(),
          NovaColetaView.routeName: (ctx) => NovaColetaView(),
        },
      ),
    );
  }
}
