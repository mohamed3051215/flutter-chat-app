import 'dart:io';

import 'package:chat_app/commands/change_screens.dart';
import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obs = true;
  bool loading = false;
  void hi() {
    setState(() {
      _obs = !_obs;
    });
  }

  File imagePath;
  final ImagePicker imagePicker = ImagePicker();
  SharedPreferences prefs;
  button(context) {
    if (!loading)
      return Container(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
            onPressed: () {
              signUp(context);
            },
            child: Text("Sign Up", style: TextStyle(fontSize: 20))),
      );
    else
      return CircularProgressIndicator();
  }

  TextEditingController n = TextEditingController();
  TextEditingController e = TextEditingController();
  TextEditingController p = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  showError(BuildContext context, error) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(error.toString()),
      ),
    );
  }

  setPrefs() async {
    var shared = await SharedPreferences.getInstance();
    setState(() {
      prefs = shared;
    });
    Inform("SHARED PREFS : $prefs");
  }

  @override
  void initState() {
    setPrefs();
    super.initState();
  }

  signUp(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      try {
        if (imagePath != null) {
          setState(() {
            loading = true;
          });
          await Firebase.initializeApp();

          UserCredential result = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: e.text, password: p.text)
              .onError((error, stackTrace) {
            setState(() {
              loading = false;
            });
            return showError(context, error);
          });
          await FirebaseFirestore.instance
              .collection("users")
              .doc(result.user.uid)
              .set({
            "name": n.text,
            "email": e.text,
            "uid": result.user.uid,
            "password": p.text,
            "imageUrl": null
          }).onError((error, stackTrace) {
            showError(context, error);
            setState(() {
              loading = false;
            });
          });
          if (result != null) {
            var ref = FirebaseStorage.instance
                .ref()
                .child("images/${result.user.uid}");
            var task = await ref.putFile(imagePath);
            task.ref.getDownloadURL().then((value) async {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(result.user.uid)
                  .update({"imageUrl": value});
            });

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
        } else {
          showError(context, "You should pick an image");
        }
      } catch (error) {
        showError(context, error);
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget image(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Container(
            height: 300,
            width: 300,
            child: Image.file(imagePath, fit: BoxFit.cover)),
      );
    } else
      return Image.asset('assets/images/unknown.png', fit: BoxFit.fill);
  }

  showPickerDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => SimpleDialog(
              title: Text("Pick An Image"),
              children: [
                TextButton(
                  onPressed: () async {
                    final pickedFile = await imagePicker.getImage(
                        source: ImageSource.gallery, imageQuality: 20);
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = File(pickedFile.path);
                      });
                      popScreen(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.storage),
                      Text("Storage",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final pickedFile = await imagePicker.getImage(
                        source: ImageSource.camera, imageQuality: 20);
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = File(pickedFile.path);
                      });
                      popScreen(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      Text("Camera",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up !"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: image(context)),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      showPickerDialog(context);
                    },
                    child:
                        Text("Pick An Image", style: TextStyle(fontSize: 20))),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: n,
                      validator: (String text) {
                        if (text.isEmpty) return "Name Address is Empty";
                        if (text.length < 3)
                          return "Invalid Email Address";
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 18),
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
                      validator: (String text) {
                        if (text.isEmpty) return "Password is Empty";
                        if (text.length < 6)
                          return "Week Password";
                        else
                          return null;
                      },
                      controller: p,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_obs
                              ? Icons.visibility_off
                              : Icons.remove_red_eye),
                          onPressed: () {
                            hi();
                          },
                        ),
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
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Login ",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                            text: "Has an account? ",
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
