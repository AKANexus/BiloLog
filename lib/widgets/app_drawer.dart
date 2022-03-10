import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
          child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.hail),
            title: const Text("Opção 1"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.hail),
            title: const Text("Opção 2"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              final authProvider =
                  Provider.of<AuthenticationProvider>(context, listen: false);
              authProvider.logOut();
              Navigator.of(context).pop();
            },
          )
        ],
      )),
    );
  }
}
