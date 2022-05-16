import 'package:bilolog/models/cargo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    //final remessasProvider = Provider.of<RemessasAPI>(context, listen: false);
    return SafeArea(
      child: Drawer(
          child: Column(
        children: [
          (authProvider.authorization == Cargo.supervisor ||
                  authProvider.authorization == Cargo.administrador)
              ? ListTile(
                  leading: const Icon(Icons.hail),
                  title: const Text("Coletar"),
                  onTap: () {
                    authProvider.specialAuth = Cargo.coletor;
                    // remessasProvider.getRemessas(onError: () {});
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          (authProvider.authorization == Cargo.supervisor ||
                  authProvider.authorization == Cargo.administrador)
              ? ListTile(
                  leading: const Icon(Icons.hail),
                  title: const Text("Receber"),
                  onTap: () {
                    authProvider.specialAuth = Cargo.galeraDoCD;
                    // remessasProvider.getRemessas(onError: () {});
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          (authProvider.authorization == Cargo.administrador)
              ? ListTile(
                  leading: const Icon(Icons.hail),
                  title: const Text("Entregar"),
                  onTap: () {
                    authProvider.specialAuth = Cargo.motocorno;
                    // remessasProvider.getRemessas(onError: () {});
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          (authProvider.authorization == Cargo.supervisor)
              ? const Divider()
              : Container(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              authProvider.logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          )
        ],
      )),
    );
  }
}
