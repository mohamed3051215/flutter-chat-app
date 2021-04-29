import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/signup_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obs = true;
  bool loading = false;
  SharedPreferences prefs;
  bool logged;
  String uid;
  void hi() {
    setState(() {
      _obs = !_obs;
    });
  }

  button(BuildContext context) {
    if (!loading)
      return Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
            onPressed: () {
              login(context);
            },
            child: Text("Login", style: TextStyle(fontSize: 20))),
      );
    else
      return CircularProgressIndicator();
  }

  TextEditingController e = TextEditingController();
  TextEditingController p = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  showError(BuildContext context, error) {
    return showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(title: Text("Error"), content: Text(error)));
  }

  login(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          loading = true;
        });
        await Firebase.initializeApp();
        var result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: e.text, password: p.text)
            // ignore: missing_return
            .onError((error, stackTrace) {
          setState(() {
            loading = false;
          });
          showError(context, error.toString());
        });
        if (result != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(result.user.uid)));
          prefs.setBool("logged", true);
          prefs.setString("uid", result.user.uid);
        }
        setState(() {
          loading = false;
        });
      } catch (e) {
        showError(context, e.toString());
        setState(() {
          loading = false;
        });
      }
    }
  }

  setPrefs() async {
    await Firebase.initializeApp();
    var shared = await SharedPreferences.getInstance();
    setState(() {
      prefs = shared;
    });
    Inform("SHARED PREFS : $prefs");
    setState(() {
      logged = prefs.getBool("logged");
      uid = prefs.getString("uid");
    });
  }

  @override
  void initState() {
    setPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (logged != null && uid != null) {
      if (logged == true) {
        return HomeScreen(uid);
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text("Login !"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: e,
                          validator: (String text) {
                            if (text.isEmpty) return "Email Address is Empty";
                            if (text.length < 10 ||
                                !text.contains("@") ||
                                !text.contains(".com"))
                              return "Invalid Email Address";
                            else
                              return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email Address",
                            hintText: "You@gmail.com",
                            suffixIcon: Icon(Icons.account_circle),
                            hintStyle: TextStyle(color: Colors.grey),
                            labelStyle: TextStyle(fontSize: 18),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: p,
                          validator: (String text) {
                            if (text.isEmpty) return "Password is Empty";
                            if (text.length < 6)
                              return "Week Password";
                            else
                              return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  hi();
                                },
                                icon: _obs
                                    ? Icon(Icons.remove_red_eye)
                                    : Icon(Icons.visibility_off)),
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            labelStyle: TextStyle(fontSize: 18),
                          ),
                          obscureText: _obs,
                        ),
                        SizedBox(height: 20),
                        button(context),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Sign up ",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                                text: "Has no account? ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
          ),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Login !"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: e,
                        validator: (String text) {
                          if (text.isEmpty) return "Email Address is Empty";
                          if (text.length < 10 ||
                              !text.contains("@") ||
                              !text.contains(".com"))
                            return "Invalid Email Address";
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email Address",
                          hintText: "You@gmail.com",
                          suffixIcon: Icon(Icons.account_circle),
                          hintStyle: TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(fontSize: 18),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: p,
                        validator: (String text) {
                          if (text.isEmpty) return "Password is Empty";
                          if (text.length < 6)
                            return "Week Password";
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                hi();
                              },
                              icon: _obs
                                  ? Icon(Icons.remove_red_eye)
                                  : Icon(Icons.visibility_off)),
                          border: OutlineInputBorder(),
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 18),
                        ),
                        obscureText: _obs,
                      ),
                      SizedBox(height: 20),
                      button(context),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Sign up ",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                              text: "Has no account? ",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
          ),
        ),
      );
    }
  }
}
