import 'package:flutter/material.dart';
import './app/pages/app_widget.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(AppWidget());
}

//Positioned.fill(
//child: Align(
//alignment: Alignment.centerRight,
//child: ....
//),
//),
