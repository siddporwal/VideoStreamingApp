import 'package:flutter/material.dart';
import './Auth/Login.dart';
import './Auth/SignUp.dart';
import './Homepage.dart';

import 'Auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (authStatus == AuthStatus.notSignedIn) {
      return MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xfff85665),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Signup',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                ],
              ),
              title: Text(''),
            ),
            body: TabBarView(
              children: [
                SignUp(
                  auth: widget.auth,
                  onSignedIn: _signedIn,
                ),
                Login(
                  auth: widget.auth,
                  onSignedIn: _signedIn,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return HomePage(
        auth: widget.auth,
        onSignOut: _signedOut,
      );
    }
  }
}
