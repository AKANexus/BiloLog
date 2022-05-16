// ignore_for_file: prefer_const_constructors

import 'package:bilolog/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({Key? key}) : super(key: key);
  static const String routeName = "/authenticationView";

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final _loginFocusNode = FocusNode(); //Disposable
  final _passwordFocusNode = FocusNode(); //Disposable

  @override
  void dispose() {
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        setState(() {
          version = packageInfo.version;
          buildNumber = packageInfo.buildNumber;
        });
      });
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);

      authProvider.checkForLogIn();

      _isInit = false;
    }
    super.didChangeDependencies();
  }

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
    // setState(() {
    //   _isBusy = true;
    // });
    // await Provider.of<AuthenticationProvider>(context, listen: false)
    //     .teste(context);
    // setState(() {
    //   _isBusy = false;
    // });
    // return;
    if (kDebugMode) {
      setState(() {
        _isBusy = true;
      });
      _formKey.currentState?.save();
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final normalizedUsername = _username!.toLowerCase().trim();
      await authProvider.logIn(normalizedUsername, "trilha123", _onError);
      setState(() {
        _isBusy = false;
      });
    } else {
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
        final normalizedUsername = _username!.toLowerCase().trim();
        await authProvider.logIn(normalizedUsername, _password!, _onError);
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  String version = "";
  String buildNumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Log Control",
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
                              key: const Key("usernameField"),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                              focusNode: _loginFocusNode,
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
                                label: Text("Usuário",
                                    semanticsLabel: "Campo Usuário"),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              key: Key("passwordField"),
                              focusNode: _passwordFocusNode,
                              onSaved: (value) {
                                _password = value;
                              },
                              onFieldSubmitted: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _submit();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "A senha não pode estar em branco.";
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                label: Text("Senha",
                                    semanticsLabel: "Campo Senha"),
                              ),
                              obscureText: false,
                            ),
                            SizedBox(
                              height: 45,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submit();
                              },
                              child: Text("Login"),
                            ),
                            SizedBox(height: 40),
                            Text(
                              "$version+$buildNumber",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 8,
                              ),
                            ),
                          ]),
                    ),
                  )
                ],
              ),
            ),
            if (_isBusy)
              Container(
                child: Center(
                  child: SizedBox(
                    height: 300,
                    width: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
