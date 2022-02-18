import 'package:bilolog/providers/authProvider.dart';
import 'package:bilolog/views/coletasView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationView extends StatefulWidget {
  AuthenticationView({Key? key}) : super(key: key);
  static const String routeName = "/authenticationView";

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isBusy = false;
  String? _username;
  String? _password;

  void _onError(String errorMessage) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Erro ao tentar fazer login"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    print("Attempting to login");
    if (_formKey.currentState?.validate() == false) {
      return;
    } else {
      _formKey.currentState?.save();
      if (_username == null || _password == null) return;
      setState(() {
        _isBusy = true;
      });
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final loginResult =
          await authProvider.LogIn(_username!, _password!, _onError);
      setState(() {
        _isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Trilhogística",
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(35),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            onSaved: (value) {
                              _username = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nome de usuário inválido";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              label: Text("Usuário"),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onSaved: (value) {
                              _password = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "A senha não pode estar em branco.";
                              } else {
                                return null;
                              }
                            },
                            decoration: const InputDecoration(
                              label: Text("Senha"),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 45,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _submit();
                            },
                            child: Text("Login"),
                          )
                        ]),
                  ),
                )
              ],
            ),
            if (_isBusy)
              Container(
                child: Center(
                  child: Container(
                    height: 300,
                    width: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                color: Colors.black54,
              ),
          ],
        ),
      ),
    );
  }
}
