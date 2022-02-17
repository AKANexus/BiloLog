import 'package:flutter/material.dart';

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
          ListTile(
            leading: Icon(Icons.hail),
            title: Text("Opção 3"),
            onTap: () {},
          )
        ],
      )),
    );
  }
}
