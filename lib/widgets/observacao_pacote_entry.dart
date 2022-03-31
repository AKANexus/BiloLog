import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bilolog/widgets/take_picture.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ObservacaoPacoteEntry extends StatefulWidget {
  ObservacaoPacoteEntry({Key? key}) : super(key: key);

  @override
  State<ObservacaoPacoteEntry> createState() => _ObservacaoPacoteEntryState();
}

class _ObservacaoPacoteEntryState extends State<ObservacaoPacoteEntry> {
  final _formKey = GlobalKey<FormState>();

  final reasonTextController = TextEditingController();

  final _reasonFocusNode = FocusNode(); //Disposable
  //final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  @override
  void dispose() {
    _reasonFocusNode.dispose();
    super.dispose();
  }

  CameraDescription? _currentCamera;

  @override
  void initState() {
    super.initState();
    if (_currentCamera == null) {
      availableCameras().then((value) => _currentCamera = value.first);
    }
  }

  void _addImageToCarousel() async {
    final XFile? _toAdd = await showDialog(
        context: context,
        builder: (ctx) {
          return TakePictureWidget(
            camera: _currentCamera!,
          );
        });
    if (_toAdd == null) return;
    setState(() {
      _images.add(_toAdd);
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> info = {};
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
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: reasonTextController,
                decoration: const InputDecoration(
                  label: Text("Observação (obrigatório)"),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              child: Column(
                children: [
                  Text("Envie as fotos"),
                  SizedBox(
                    height: 58,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, ix) {
                        return Container(
                          margin: EdgeInsets.all(2),
                          height: 60,
                          width: 60,
                          child: Image.file(File(_images[ix].path)),
                        );
                      },
                      itemCount: _images.length,
                    ),
                  ),
                  TextButton(
                    child: Text("Tirar foto..."),
                    onPressed: () {
                      _addImageToCarousel();
                    },
                  ),
                ],
              ),
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
                  if (_formKey.currentState?.validate() == false) {
                    return;
                  }
                  if (_images.isNotEmpty) {
                    info['images'] = _images;
                  }
                  if (reasonTextController.text.isNotEmpty) {
                    info['observacao'] = reasonTextController.text;
                    Navigator.of(context).pop(info);
                  } else {
                    info['status'] = false;
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
