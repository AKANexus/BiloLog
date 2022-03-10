import 'dart:io';

import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/authProvider.dart';
import 'package:bilolog/providers/operacao_pacote_API.dart';
import 'package:bilolog/providers/operacao_remessa_API.dart';
import 'package:bilolog/providers/remessas_API.dart';
import 'package:bilolog/views/authView.dart';
import 'package:bilolog/views/lista_de_remessas.dart';
import 'package:bilolog/views/nova_remessa_view.dart';
import 'package:bilolog/views/pacote_detalhe_view.dart';
import 'package:bilolog/views/pacotes_da_remessa_view.dart';
import 'package:bilolog/views/remessa_QR_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  //HttpOverrides.global = MyHttpOverrides();
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
        return RemessasView();
      case Cargo.Administrador:
        return const Text("Falha ao obter autorização.");
      case Cargo.Motocorno:
        return RemessasView();
      case Cargo.GaleraDoCD:
        return RemessasView();
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
        ChangeNotifierProxyProvider<AuthenticationProvider, RemessasAPI>(
            create: (_) => RemessasAPI(),
            update: (_, auth, previousProvider) =>
                previousProvider!..authProvider = auth),
        ChangeNotifierProxyProvider<AuthenticationProvider,
                OperacaoDeRemessaAPI>(
            create: (_) => OperacaoDeRemessaAPI(),
            update: (_, auth, previousProvider) =>
                previousProvider!..authProvider = auth),
        ChangeNotifierProxyProvider<AuthenticationProvider,
                OperacaoDePacoteAPI>(
            create: (_) => OperacaoDePacoteAPI(),
            update: (_, auth, previousProvider) =>
                previousProvider!..authProvider = auth),
      ],
      child: MaterialApp(
        title: 'LogControl',
        theme: ThemeData(
            // primarySwatch: Colors.blue,
            colorScheme: ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.lightBlueAccent,
                tertiary: Colors.blueGrey,
                onPrimary: Colors.white,
                errorContainer: Color.fromARGB(255, 255, 190, 190))),
        home: Consumer<AuthenticationProvider>(
          builder: (context, auth, _) {
            print("auth.isLoggedIn: ${auth.isLoggedIn}");
            return auth.isLoggedIn
                ? selectStartingWidget(auth.authorization)
                : AuthenticationView();
          },
        ),
        routes: {
          RemessasView.routeName: (ctx) => RemessasView(),
          RemessaPacotesView.routeName: (ctx) => RemessaPacotesView(),
          PacoteDetalheView.routeName: (ctx) => PacoteDetalheView(),
          RemessaQRScanView.routeName: (ctx) => RemessaQRScanView(),
          NovaRemessaView.routeName: (ctx) => NovaRemessaView(),
        },
      ),
    );
  }
}
