import './camera_page.dart';
import 'package:flutter/material.dart';

import 'package:splashscreen/splashscreen.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //use 'controller' variable to access controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SplashScreen(
      seconds: 5,
      image: Image.asset('assets/images/mask.png'),
      navigateAfterSeconds: CameraPage.routeName,
      title: Text('ENMASKEDT APP',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
      backgroundColor: Colors.white,
      loaderColor: Colors.black,
      loadingText: Text(
        "Desenvolvido por Lucas Cicco",
        style: TextStyle(color: Colors.black, fontSize: 16.0),
      ),
    ));
  }
}
