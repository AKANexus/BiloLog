import 'package:flutter/material.dart';

class ObservacaoPacoteEntry extends StatefulWidget {
  const ObservacaoPacoteEntry({Key? key}) : super(key: key);

  @override
  State<ObservacaoPacoteEntry> createState() => _ObservacaoPacoteEntryState();
}

class _ObservacaoPacoteEntryState extends State<ObservacaoPacoteEntry> {
  final reasonTextController = TextEditingController();

  final _reasonFocusNode = FocusNode(); //Disposable

  @override
  void dispose() {
    _reasonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String info;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: (MediaQuery.of(context).viewInsets.bottom) + 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onSubmitted: (_) {
                if (reasonTextController.text.isNotEmpty) {
                  info = reasonTextController.text;
                  Navigator.of(context).pop(info);
                } else {
                  Navigator.of(context).pop();
                }
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: reasonTextController,
              decoration: const InputDecoration(
                label: Text("Motivo da falha na entrega (obrigatório)"),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Enviar",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                onPressed: () {
                  if (reasonTextController.text.isNotEmpty) {
                    info = reasonTextController.text;
                    Navigator.of(context).pop(info);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
