import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authProvider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
          child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.hail),
            title: Text("Opção 1"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.hail),
            title: Text("Opção 2"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              final authProvider =
                  Provider.of<AuthenticationProvider>(context, listen: false);
              authProvider.LogOut();
              Navigator.of(context).pop();
            },
          )
        ],
      )),
    );
  }
}
