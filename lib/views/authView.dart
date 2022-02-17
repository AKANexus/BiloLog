import 'package:bilolog/views/coletasView.dart';
import 'package:flutter/material.dart';

class AuthenticationView extends StatefulWidget {
  AuthenticationView({Key? key}) : super(key: key);

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isBusy = false;

  void _submit() {
    if (_formKey.currentState?.validate() == false) {
      // Invalid!
      return;
    } else {
      _formKey.currentState?.save();
      setState(() {
        _isBusy = true;
      });
      //TODO: Implementar autenticação via API
      Navigator.of(context).pushReplacementNamed(ColetasView.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                        decoration: const InputDecoration(
                          label: Text("Usuário"),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
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
      ),
    );
  }
}
