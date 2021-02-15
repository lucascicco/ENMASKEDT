import './camera_page.dart';
import './home_page.dart';
import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENMASKEDT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => HomePage(),
        CameraPage.routeName: (ctx) => CameraPage()
      },
    );
  }
}
