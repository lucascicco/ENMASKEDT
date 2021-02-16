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
  CameraDescription description;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  bool isWorking = false;

  bool masked = false;
  int currentState = 0;

  initCamera() {
    description = cameras.firstWhere((CameraDescription cameraDescription) =>
        cameraDescription.lensDirection == cameraLensDirection);

    cameraController = CameraController(description, ResolutionPreset.medium);

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  getImageFromFrame(),
                  maskStatus()
                },
            });
      });
    });
  }

  Future<bool> getRunModelOnFrame() async {
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

  getImageFromFrame() async {
    if (imgCamera != null) {
      var result = await getRunModelOnFrame();

      setState(() {
        masked = result;
      });
    }
  }

  maskStatus() async {
    if (masked) {
      setState(() {
        currentState = 1;
      });

      await Future.delayed(Duration(seconds: 4));

      var maskedTwo = await getRunModelOnFrame();

      setState(() {
        currentState = maskedTwo ? 2 : 3;
      });

      await Future.delayed(Duration(seconds: 2));
    } else {
      setState(() {
        currentState = 0;
      });
    }

    isWorking = false;
  }

  CameraStatus statusNamed() {
    switch (currentState) {
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
      case 2:
        return CameraStatus(
            status: "Prossiga",
            color: Colors.green,
            icon: Icons.verified_user_sharp);
      case 3:
        return CameraStatus(
            status: "Máscara retirada",
            color: Colors.red,
            icon: Icons.error_outline);
      default:
        return CameraStatus(
            status: "Entrada Proibida",
            color: Colors.red,
            icon: Icons.error_outline);
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    CameraStatus status = statusNamed();

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
              Image.asset(
                'assets/images/mask.png',
                width: size.width * 0.2,
                height: size.height * 0.1,
              ),
              Expanded(
                child: Text(
                  "Verificador de máscara",
                  style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                          letterSpacing: 5, fontSize: size.height * 0.05)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: cameraController.value.isInitialized
                      ? Border.all(color: status.color)
                      : null),
              child: cameraController.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: size.height * 0.6,
                          child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: Opacity(
                                opacity: currentState == 1 ? 0.5 : 1.0,
                                child: CameraPreview(cameraController)),
                          ),
                        ),
                        if (currentState == 1)
                          Center(
                              child: Text("Não retire sua máscara",
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
