import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureWidget extends StatefulWidget {
  const TakePictureWidget({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<TakePictureWidget> createState() => _TakePictureWidgetState();
}

class _TakePictureWidgetState extends State<TakePictureWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  var _currentFlashMode = FlashMode.off;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium,
        enableAudio: false);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    //print('Controller disposed');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeControllerFuture,
        builder: (ctx, sn) {
          if (sn.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Column(
                  children: [
                    CameraPreview(_controller),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                switch (_currentFlashMode) {
                                  case FlashMode.off:
                                    _currentFlashMode = FlashMode.torch;
                                    break;
                                  case FlashMode.torch:
                                    _currentFlashMode = FlashMode.off;
                                    break;
                                  default:
                                    break;
                                }
                                setState(() {
                                  _controller.setFlashMode(_currentFlashMode);
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 50),
                                child: Icon(
                                  Icons.flash_on,
                                  size: 30,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary),
                                foregroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                            TextButton(
                              onPressed: !_isBusy
                                  ? () async {
                                      setState(() {
                                        _isBusy = true;
                                      });
                                      final file =
                                          await _controller.takePicture();
                                      _controller.pausePreview();

                                      setState(() {
                                        _isBusy = false;
                                      });
                                      Navigator.of(context).pop(file);
                                    }
                                  : null,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 50),
                                child: Icon(
                                  Icons.camera,
                                  size: 30,
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary),
                                foregroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                          ]),
                    )
                  ],
                ),
                _isBusy
                    ? Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
