import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import './Auth.dart';

import './test.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.auth});
  final BaseAuth auth;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = Firestore.instance;

  Future<FirebaseUser> id1 = FirebaseAuth.instance.currentUser();
  String id;

  final databasereference = Firestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'App Name!',
            style: TextStyle(
              color: Color(0xfff85665),
            ),
          ),
          elevation: 0.0,
          leading: IconButton(
            icon: Image.asset(
              'images/logo.png',
              width: 50.0,
              height: 50.0,
            ),
            onPressed: null,
          ),
        ),
        body: Center(
          child: LoadDataFromFirestore(),
        ),
      ),
    );
  }
}
