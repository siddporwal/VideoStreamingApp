import 'dart:async';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'Auth.dart';
import './Auth/Database.dart';
import './root_page.dart';
import './widgets/player.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoledstate = GlobalKey<ScaffoldState>();
  String fname;
  bool show = false;
  bool savebutton;
  String uName;
  bool usercontainer;
  DatabaseService database;
  String pass;
  String newpass;

  var _fname = TextEditingController(text: 'first name');

  final _newpassword = TextEditingController();
  final _confirmnewpassword = TextEditingController();
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => {CircularProgressIndicator()});
    savebutton = false;
    usercontainer = false;
    getName("firstName");

    getUserVideo().then((results) {
      setState(() {
        frameit = list2.length;
        print(frameit);
      });
    });
  }

  void _signout() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RootPage(
                    auth: Auth(),
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _fname = TextEditingController(text: fname);

    return KeyboardDismissOnTap(
      child: Scaffold(
          key: _scaffoledstate,
          resizeToAvoidBottomInset: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: usercontainer == false
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  isExtended: true,
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Color(0xfff85665),
                  ),
                  label: Text(
                    "LogOut",
                    style: TextStyle(color: Color(0xfff85665)),
                  ),
                  onPressed: _signout,
                  tooltip: "LogOut",
                ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(200.0),
            child: Container(
              color: Color(0xfff85665),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: RaisedButton.icon(
                      icon: Icon(
                        Icons.settings,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: Text('Setting',
                          style:
                              TextStyle(color: Colors.white, fontSize: 15.0)),
                      onPressed: () {
                        setState(() {
                          if (usercontainer) {
                            usercontainer = !usercontainer;
                          } else {
                            usercontainer = !usercontainer;
                          }
                        });
                      },
                      elevation: 2.0,
                      color: Color(0xfff85665),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  CircleAvatar(
                    child: Image.network("image url"),
                    maxRadius: 40,
                    backgroundColor: Colors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      "@${uName}",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: KeyboardDismissOnTap(
              child: Column(
                children: <Widget>[
                  usercontainer == true ? user() : Container(),
                  usercontainer == true
                      ? Container()
                      : Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Center(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'My Posts',
                                    style: TextStyle(
                                      color: Color(0xfff85665),
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
                  usercontainer == true
                      ? Container()
                      : Container(
                          height: MediaQuery.of(context).size.height - 280,
                          child: showDrivers(),
                        )
                ],
              ),
            ),
          )),
    );
  }

  Widget user() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        errorText: _fname.text.isEmpty
                            ? 'Full name cannot be empty'
                            : ''),
                    controller: _fname,
                    onChanged: (value) {
                      fname = value;
                    },
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
            color: Color(0xfff85665),
            onPressed: _fname.text.isNotEmpty
                ? () async {
                    await DatabaseService.updatePersonalData(_fname.text)
                        .then((value) {
                      SnackBar snackbar = SnackBar(
                        content: Text('Details Updated!'),
                        duration: Duration(seconds: 5),
                      );
                      _scaffoledstate.currentState.showSnackBar(snackbar);
                    });
                  }
                : null,
            child: Text(
              'Update',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        errorText: _newpassword.text.isEmpty ? '' : null),
                    controller: _newpassword,
                    onChanged: (value) {
                      newpass = value;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        errorText:
                            _confirmnewpassword.text.isEmpty ? '' : null),
                    controller: _confirmnewpassword,
                    onChanged: (value) {
                      setState(() {
                        pass = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          RaisedButton(
            color: Color(0xfff85665),
            onPressed: (_newpassword.text.isNotEmpty &&
                    _confirmnewpassword.text.isNotEmpty &&
                    _newpassword.text == _confirmnewpassword.text)
                ? () {
                    print(_confirmnewpassword.text);
                    _changePassword(pass);
                  }
                : null,
            child: Text(
              'Update Password',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //Pass in the password to updatePassword.
    try {
      try {
        user.updatePassword(password);
        print("Succesfull changed password");
        SnackBar snackbar = SnackBar(
          content: Text('Password Changed Sucessfully please login again.'),
          duration: Duration(seconds: 5),
        );
        _scaffoledstate.currentState.showSnackBar(snackbar);
      } on Exception catch (e) {
        print(e);
        SnackBar snackbar = SnackBar(
          content: Text('Please do recent login to change password'),
          duration: Duration(seconds: 5),
        );
        _signout();
        _scaffoledstate.currentState.showSnackBar(snackbar);
      }
      _signout();
    } catch (e) {
      print(e);
    }
  }

  getName(String data) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var use = await Firestore.instance
        .collection('collectionName')
        .document(user.uid)
        .get();
    if (data == "firstName") {
      setState(() {
        fname = use['fullName'];
        uName = use['userName'];
      });
    }
  }

  var frameit;

  Widget showDrivers() {
    //check if querysnapshot is null
    if (frameit == null) {
      return Countdown(
        seconds: 2,
        build: (context, double time) => show
            ? Center(child: Text("No Videos Available"))
            : Center(child: CircularProgressIndicator()),
        interval: Duration(milliseconds: 100),
        onFinished: () {
          setState(() {
            show = true;
          });
        },
      );
    } else {
      if (frameit != null) {
        return StaggeredGridView.countBuilder(
          primary: false,
          crossAxisCount: 4,
          itemCount: frameit,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Player(video: list2[index]);
                  },
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.network(
                list3[index],
                fit: BoxFit.cover,
                height: 50,
              ),
            ),
          ),
          staggeredTileBuilder: (int index) =>
              new StaggeredTile.count(2, index.isEven ? 2 : 2),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  //final CollectionReference _postsCollectionReference =
  // Firestore.instance.collection('kudos-user');
  List list2;
  List list3;
  //get firestore instance
  getUserVideo() async {
    // FirebaseUser user = await FirebaseAuth.instance.currentUser();
    // return await Firestore.instance
    //     .collection('kudos-user')
    //     .document(user.uid)

    var firebaseUser = await FirebaseAuth.instance.currentUser();
    return Firestore.instance
        .collection("collectionName")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      print("---------------------");
      list2 = value.data['videoUrl'].map((element) => element).toList();
      list3 = value.data['coverUrl'].map((element) => element).toList();
      print(list2);
      // print(value.data['videoUrl']);
      print("---------------------");
    });
  }
}
