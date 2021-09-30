// the original source of this file is
// https://medium.com/analytics-vidhya/integrating-tensorflowlite-with-flutter-for-computer-vision-6c82d1e5bccd#id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjhkOTI5YzYzZmYxMDgyYmJiOGM5OWY5OTRmYTNmZjRhZGFkYTJkMTEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJuYmYiOjE2MzI5NTM3MTIsImF1ZCI6IjIxNjI5NjAzNTgzNC1rMWs2cWUwNjBzMnRwMmEyamFtNGxqZGNtczAwc3R0Zy5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExNzI5Njk5ODEzMTQ4MTM3MDAxMSIsImVtYWlsIjoiZ2tpYmFuemFpdEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMjE2Mjk2MDM1ODM0LWsxazZxZTA2MHMydHAyYTJqYW00bGpkY21zMDBzdHRnLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwibmFtZSI6IkdpdmVuIEtpYmFuemEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2lqSzJ0bmtzZ1Jwbm1ReElmbExOa09rTXBtcWZqSTBIdi1ieGRNPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6IkdpdmVuIiwiZmFtaWx5X25hbWUiOiJLaWJhbnphIiwiaWF0IjoxNjMyOTU0MDEyLCJleHAiOjE2MzI5NTc2MTIsImp0aSI6ImM4NjIzNjVlMjFiYjk4ODVlOWUzOWNhMTFjYjBkOTFlZGRkZTM3ZWIifQ.QxwrHvckMv19-JldunMkS2q202HVXPR-jovxj7eV0QImSa3LdqAHLkf-O-k3I3WC0zHyAHYgChLIefof6DUz56P4LQkkEUOiCYjMmffXLNcHspwBaWzu-29g-XMPtVVus6r-gTvSJvtBFog1yPyFJd6wnAaH6nU2MNUHt-14wBXno3j9xua_rb7LQozk3VZk8uUE97MlV5exHg-ljKvNiNsIuEvjvWI9dDE0eHwmV2WjnyLl5y31eQVAr6Pyqj1twPdfHmWrctQwKl1_hco2hepHZ-nph9Y3DH_qAzR-ZESgOlawLCjaggnmVpwdsaH5BrV8cD2VQoXjrR9-MuFPKw

// i then used code from the following 2 sites to make it work for my needs
// https://pub.dev/packages/camera_ignore_kitkat/example
// https://pub.dev/packages/camera

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  Camera(this.cameras, this.setRecognitions);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? cameraController;
  bool isDetecting = false;
  String? imagePath;
  FlashMode? flash;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // alternative method ...
    // controller = CameraController(cameras[0], ResolutionPreset.max);

    cameraController =
        CameraController(widget.cameras.first, ResolutionPreset.high);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        flash = FlashMode.off;
      });

      cameraController!.startImageStream((image) {
        if (!isDetecting) {
          // isDetecting = true;

          // Tflite.runModelOnFrame(
          //   bytesList: image.planes.map((plane) {
          //     return plane.bytes;
          //   }).toList(),
          //   imageHeight: image.height,
          //   imageWidth: image.width,
          //   numResults: 1,
          // ).then((value) {
          //   if (value.isNotEmpty) {
          //     widget.setRecognitions(value);
          //     isDetecting = false;
          //   }
          // });
        }
      });
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraController != null) {
        onNewCameraSelected(cameraController!.description);
      }
    }
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController?.dispose();
    }
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    cameraController!.addListener(() {
      if (mounted)
        setState(() {
          flash = FlashMode.off;
        });
      if (mounted) showInSnackBar("Camera mounted");
      if (cameraController!.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController!.value.errorDescription}');
      }
    });

    try {
      await cameraController!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  Future<String> takePicture() async {
    if (!cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return "";
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return "";
    }

    try {
      var file = await cameraController!.takePicture();
      // file.saveTo(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return "";
    }
    return filePath;
  }

  cameraOptions() {
    return Container(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: () {}, child: Text("Cap")),
          ElevatedButton(
              onPressed: () {
                // cameraController!.setFlashMode(FlashMode.torch);

                if (flash == FlashMode.off) {
                  cameraController!.setFlashMode(FlashMode.torch);
                  setState(() {
                    flash = FlashMode.torch;
                  });
                } else {
                  cameraController!.setFlashMode(FlashMode.off);
                  setState(() {
                    flash = FlashMode.off;
                  });
                }
              },
              child: Text("Flash")),
          ElevatedButton(onPressed: () {}, child: Text("Pause"))
        ],
      ),
    );
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void logError(String code, String? message) =>
      print('Error: $code\nError Message: $message');

  @override
  Widget build(BuildContext context) {
    if (!cameraController!.value.isInitialized) {
      return Container();
    }

    // print(cameraController!.value.aspectRatio);
    // print(1 / (cameraController!.value.aspectRatio));

    // aspect ratio returns camera width/height
    // we use 1/aspect ratio to get height/width instead

    // return Transform.scale(
    //   scale: 1 / cameraController!.value.aspectRatio,
    //   child: Center(
    //     child: AspectRatio(
    //       aspectRatio: 1 / cameraController!.value.aspectRatio,
    //       child: CameraPreview(cameraController!),
    //     ),
    //   ),
    // );

    // the following returns the full camera screen... not scaled or anything
    // return MaterialApp(home: CameraPreview(cameraController!));
    return MaterialApp(
      home: Stack(
        children: [
          CameraPreview(cameraController!),
          Align(
            alignment: Alignment.topRight,
            child: cameraOptions(),
          ),
        ],
      ),
    );
  }
}
