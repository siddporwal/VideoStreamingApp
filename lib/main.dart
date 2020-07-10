import 'package:flutter/material.dart';
import './splash.dart';
//import 'package:kudos/video.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'title of the app',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // home: HomePage(),
      /* home: RootPage(
        auth: Auth(),
      ),*/
      home: SplashScreen(),
    );
  }
}
