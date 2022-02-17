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
        ChangeNotifierProvider(create: (_) => ColetasProvider()),
        ChangeNotifierProvider(create: (_) => EntregasProvider()),
      ],
      child: MaterialApp(
        title: 'Bilolog',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthenticationView(),
        routes: {
          ColetasView.routeName: (ctx) => ColetasView(),
          EntregasView.routeName: (ctx) => EntregasView(),
        },
      ),
    );
  }
}
