import './root_page.dart';
import 'package:flutter/material.dart';
import './Auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RootPage(
                  auth: Auth(),
                ))));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.red),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25.0,
                      child: Icon(
                        Icons.explore,
                        color: Colors.green[200],
                        size: 40.0,
                      ),
                    ),*/
                    Container(
                      child: Image(
                        image: AssetImage("images/logo1.png"),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0),
                    ),
                    Text(
                      "Tagline",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text("....",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
