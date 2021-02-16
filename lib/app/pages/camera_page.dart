import 'package:camera/camera.dart';
import '../models/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import '../../main.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/camera';
  const CameraPage({Key key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraImage imgCamera;
  CameraController cameraController;
  bool isWorking = false;

  int currentState = 0;
  Timer _timer;
  int _start = 3;

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) async => {
              imgCamera = imageFromStream,
              if (await runModelOnFrame())
                {
                  if (!_timer.isActive)
                    {
                      currentState = 2,
                      Timer.periodic(
                        Duration(seconds: 1),
                        (Timer timer) {
                          if (_start == 0) {
                            timer.cancel();
                            currentState = 3;
                          } else {
                            _start--;
                          }
                        },
                      )
                    }
                }
              else
                {
                  currentState = 0,
                  _timer.cancel(),
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  Future<bool> runModelOnFrame() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: imgCamera.height,
          imageWidth: imgCamera.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 1,
          threshold: 0.1,
          asynch: true);

      String result = "";

      recognitions.forEach((response) {
        result = response["label"];
      });

      return result == "with_mask";
    }

    return false;
  }

  CameraStatus statusNamed(int state) {
    switch (state) {
      case 0:
        return CameraStatus(
            status: "Entrada Proibida",
            color: Colors.red,
            icon: Icons.error_outline);
      case 1:
        return CameraStatus(
            status: "Verificando...",
            color: Colors.yellow,
            icon: Icons.warning);
      case 3:
        return CameraStatus(
            status: "Prossiga",
            color: Colors.green,
            icon: Icons.verified_user_sharp);
      default:
        return CameraStatus(
            status: "Entrada Proibida",
            color: Colors.red,
            icon: Icons.error_outline);
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final CameraStatus status = statusNamed(currentState);

    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/mask.png'),
              Expanded(
                child: Text("Verificador de máscara",
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(letterSpacing: 5, fontSize: 15))),
              ),
            ],
          ),
          Container(
              width: double.infinity,
              height: size.height * 0.7,
              decoration:
                  BoxDecoration(border: Border.all(color: status.color)),
              child: cameraController.value.isInitialized
                  ? Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                        if (currentState == 2)
                          Center(
                              child: Text(_start.toString(),
                                  style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(fontSize: 30))))
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.black))),
          Container(
              width: double.infinity,
              height: size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status.icon,
                    color: status.color,
                  ),
                  SizedBox(width: 10),
                  Text(
                    status.status,
                    style: TextStyle(color: status.color, fontSize: 25.0),
                  )
                ],
              )),
        ],
      ),
    ));
  }
}
