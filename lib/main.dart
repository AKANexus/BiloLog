import 'package:bilolog/providers/error_api.dart';
import 'package:bilolog/views/entrega_pacote_ao_cliente_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:bilolog/models/cargo.dart';
import 'package:bilolog/providers/auth_provider.dart';
import 'package:bilolog/providers/operacao_pacote_api.dart';
import 'package:bilolog/providers/operacao_remessa_api.dart';
import 'package:bilolog/providers/remessas_api.dart';
import 'package:bilolog/views/auth_view.dart';
import 'package:bilolog/views/lista_de_remessas.dart';
import 'package:bilolog/views/nova_remessa_view.dart';
import 'package:bilolog/views/pacote_detalhe_view.dart';
import 'package:bilolog/views/pacotes_da_remessa_view.dart';
import 'package:bilolog/views/remessa_qr_scan_view.dart';

void main() {
  //HttpOverrides.global = MyHttpOverrides();
  initializeDateFormatting('pt-BR');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget selectStartingWidget(Cargo authorizationString) {
    //print("authorizationString: $authorizationString");
    // switch (authorizationString) {
    //   case Cargo.coletor:
    //     return const RemessasView();
    //   case Cargo.supervisor:
    //     return const RemessasView();
    //   case Cargo.motocorno:
    //     return const RemessasView();
    //   case Cargo.galeraDoCD:
    //     return const RemessasView();
    //   default:
    return const RemessasView();
    //}
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
            colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.lightBlueAccent,
                tertiary: Colors.blueGrey,
                onPrimary: Colors.white,
                errorContainer: Color.fromARGB(255, 255, 190, 190))),
        home: Consumer<AuthenticationProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn
                ? selectStartingWidget(auth.authorization)
                : const AuthenticationView();
          },
        ),
        routes: {
          RemessasView.routeName: (ctx) => const RemessasView(),
          RemessaPacotesView.routeName: (ctx) => const RemessaPacotesView(),
          PacoteDetalheView.routeName: (ctx) => const PacoteDetalheView(),
          RemessaQRScanView.routeName: (ctx) => const RemessaQRScanView(),
          NovaRemessaView.routeName: (ctx) => const NovaRemessaView(),
          EntregaPacoteView.routeName: (ctx) => const EntregaPacoteView(),
        },
      ),
    );
  }
}
