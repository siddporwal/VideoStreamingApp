import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../Auth.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

enum FormType { forgetPassword }

class _ForgetPasswordState extends State<ForgetPassword> {
  final formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoledstate = GlobalKey<ScaffoldState>();
  String _email;
  // FormType _formtype = FormType.forgetPassword;
  bool validateAndSave() {
    final form = formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void password() async {
    if (validateAndSave()) {
      try {
        var add = await widget.auth.forgotPassword(_email);
        if (add != null) {
          SnackBar snackbar = SnackBar(
            content: Text(add),
            duration: Duration(seconds: 7),
          );
          _scaffoledstate.currentState.showSnackBar(snackbar);
        } else {
          SnackBar snackbar = SnackBar(
            content: Text("Reset mail sent to: $_email"),
            duration: Duration(seconds: 7),
          );
          _scaffoledstate.currentState.showSnackBar(snackbar);
        }
      } catch (e) {
        print("Error: $e");
      }
      // AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.toString().trim(), password: _password);

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoledstate,
        body: KeyboardDismissOnTap(
          child: Padding(
            padding: const EdgeInsets.all(29.0),
            child: Container(
              child: KeyboardDismissOnTap(
                child: Form(
                  key: formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children:
                          svgImage(150) + buildInput() + buildSubmitButtons(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> svgImage(double height) {
    return [
      Image.network(
        'image url',
        height: height / 1.4,
      ),
      SizedBox(
        height: 30,
      )
    ];
  }

  List<Widget> buildInput() {
    return [
      TextFormField(
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.alternate_email),
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          labelText: "Email",
        ),
        onSaved: (value) => _email = value.toString().trim(),
        validator: (value) =>
            !EmailValidator.validate(value.toString().trim(), true)
                ? 'Not a valid email.'
                : null,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: RaisedButton(
          color: Color(0xFF017BFF),
          child: Padding(
            padding: const EdgeInsets.all(11.0),
            child: Text(
              "Reset",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          onPressed: () {
            password();
            print("submit");
          },
        ),
      ),
      FlatButton(
        child: Text(
          "Login to reset account",
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ];
  }
}
