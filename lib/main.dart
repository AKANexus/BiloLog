import 'dart:io';

import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/authProvider.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/coletaPacotesProvider.dart';
import 'package:bilolog/providers/novaColetaProvider.dart';
import 'package:bilolog/views/authView.dart';
import 'package:bilolog/views/coletasView.dart';
import 'package:bilolog/views/coletaPacoteDetalheView.dart';
import 'package:bilolog/views/coletaPacotesView.dart';
import 'package:bilolog/views/ColetaQRScanView.dart';
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

  Widget selectStartingWidget(Cargo authorizationString) {
    print("authorizationString: $authorizationString");
    switch (authorizationString) {
      case Cargo.Coletor:
        return ColetasView();
      case Cargo.Administrador:
        return const Text("Falha ao obter autorização.");
      case Cargo.Motocorno:
        return ColetasView();
      case Cargo.GaleraDoCD:
        return ColetasView();
      default:
        return const Text("Falha ao obter autorização.");
    }
  }

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
        ChangeNotifierProvider(create: (_) => ColetaPacotesProvider()),
      ],
      child: MaterialApp(
        title: 'Bilolog',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthenticationProvider>(
          builder: (context, auth, _) {
            print("auth.isLoggedIn: ${auth.isLoggedIn}");
            return auth.isLoggedIn
                ? selectStartingWidget(auth.authorization)
                : AuthenticationView();
          },
        ),
        routes: {
          ColetasView.routeName: (ctx) => ColetasView(),
          ColetaPacotesView.routeName: (ctx) => ColetaPacotesView(),
          ColetaPacoteDetalheView.routeName: (ctx) => ColetaPacoteDetalheView(),
          ColetaQRScanView.routeName: (ctx) => ColetaQRScanView(),
          NovaColetaView.routeName: (ctx) => NovaColetaView(),
        },
      ),
    );
  }
}
