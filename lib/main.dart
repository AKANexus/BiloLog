import 'package:bilolog/providers/authProvider.dart';
import 'package:bilolog/providers/coletasProvider.dart';
import 'package:bilolog/providers/entregasProvider.dart';
import 'package:bilolog/views/authView.dart';
import 'package:bilolog/views/coletasView.dart';
import 'package:bilolog/views/entregasView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
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
        },
      ),
    );
  }
}
