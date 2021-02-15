import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
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
  bool masked = false;

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);

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
                  runModelOnFrame()
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  runModelOnFrame() async {
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

      setState(() {
        masked = result == "with_mask";
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
              Text("Verificador de máscara"),
            ],
          ),
          Container(
              width: double.infinity,
              height: size.height * 0.7,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: masked ? Colors.green : Colors.red)),
              child: cameraController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: cameraController.value.aspectRatio,
                      child: CameraPreview(cameraController),
                    )
                  : Center(child: Text('Carregando...'))),
          Container(
              width: double.infinity,
              height: size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    masked ? Icons.check : Icons.error_outline,
                    color: masked ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    masked ? "Prossiga" : "Entrada proibida",
                    style: TextStyle(
                        color: masked ? Colors.green : Colors.red,
                        fontSize: 25.0),
                  )
                ],
              )),
        ],
      ),
    ));
  }
}
