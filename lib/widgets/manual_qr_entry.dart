import 'package:flutter/material.dart';

class ManualQRDataEntry extends StatefulWidget {
  const ManualQRDataEntry({Key? key}) : super(key: key);

  @override
  State<ManualQRDataEntry> createState() => _ManualQRDataEntryState();
}

class _ManualQRDataEntryState extends State<ManualQRDataEntry> {
  final idTextController = TextEditingController();
  final senderIdTextController = TextEditingController();

  final _idFocusNode = FocusNode(); //Disposable
  final _senderIdFocusNode = FocusNode(); //Disposable

  @override
  void dispose() {
    _idFocusNode.dispose();
    _senderIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> info = <String, dynamic>{};
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
              onSubmitted: (_) =>
                  Focus.of(context).requestFocus(_senderIdFocusNode),
              textInputAction: TextInputAction.next,
              focusNode: _idFocusNode,
              controller: idTextController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text("Código do Envio"),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              onSubmitted: (_) {
                if (idTextController.text.isNotEmpty &&
                    senderIdTextController.text.isNotEmpty) {
                  info['id'] = idTextController.text;
                  info['sender_id'] = senderIdTextController.text;
                }
                Navigator.of(context).pop(info);
              },
              keyboardType: TextInputType.number,
              controller: senderIdTextController,
              decoration: const InputDecoration(
                label: Text("# na parte superior da etiqueta"),
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
                  if (idTextController.text.isNotEmpty &&
                      senderIdTextController.text.isNotEmpty) {
                    info['id'] = idTextController.text;
                    info['sender_id'] = senderIdTextController.text;
                  }
                  Navigator.of(context).pop(info);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
