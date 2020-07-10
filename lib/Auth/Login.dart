import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../Auth/ForgotPassword.dart';

import '../Auth.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  _LoginState createState() => _LoginState();
}

enum FormType { login }

class _LoginState extends State<Login> {
  final formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoledstate = GlobalKey<ScaffoldState>();
  bool _obscureText = true;
  String _email;
  String _password;
  FormType _formtype = FormType.login;
  bool validateAndSave() {
    final form = formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        //if (_formtype == FormType.login) {
        String userId =
            await widget.auth.signInWithEmailAndPassword(_email, _password);
        // AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.toString().trim(), password: _password);
        print("User: $userId");
        /*} else {
          String userId = await widget.auth
              .createUserWithEmailAndPassword(_email, _password);
          // AuthResult result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.toString().trim(), password: _password);
          print("User Created, User: $userId");
        }*/
        widget.onSignedIn();
      } catch (e) {
        print("Error: $e");
        SnackBar snackbar = SnackBar(
          content: Text(e.message),
          duration: Duration(seconds: 5),
        );
        _scaffoledstate.currentState.showSnackBar(snackbar);
      }
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
              child: Center(
                child: Form(
                  key: formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextFormField(
          obscureText: _obscureText,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(Icons.remove_red_eye),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )),
          onSaved: (value) => _password = value,
          validator: (value) =>
              value.isEmpty ? 'Password can\'t be empty' : null,
        ),
      ),
      FlatButton(
          child: Text("Forgot Password"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetPassword(
                  auth: Auth(),
                ),
              ),
            );
          })
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 0),
        child: RaisedButton(
          color: Color(0xfff85665),
          child: Padding(
            padding: const EdgeInsets.all(11.0),
            child: Text(
              "Login",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          onPressed: validateAndSubmit,
        ),
      ),
    ];
  }
}
