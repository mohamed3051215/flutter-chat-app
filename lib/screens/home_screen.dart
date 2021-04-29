import 'dart:async';

import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/widgets/contacts.dart';
import 'package:chat_app/widgets/floating_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'add_contact_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final result;

  HomeScreen(this.result);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  showError(BuildContext context, error) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(error.toString()),
      ),
    );
  }

  SharedPreferences prefs;

  setPrefs() async {
    await Firebase.initializeApp();
    SharedPreferences _shared = await SharedPreferences.getInstance();
    setState(() {
      prefs = _shared;
    });
    Inform("SHARED PREFS : $prefs");
  }

  var friends;
  var uid;
  Future<void> logOut(context) async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.signOut();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool("logged", false);
      pref.setString("uid", 'null');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (error) {
      showError(context, error);
    }
  }

  hi() {
    setState(() {
      uid = widget.result;
    });
    print("this is my id" + widget.result.toString());
    print(uid);
  }

  addContact(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddContactScreen()));
  }

  @override
  void initState() {
    getDocs();
    hi();
    super.initState();
  }

  getDocs() async {
    var store =
        await FirebaseFirestore.instance.collection(uid.toString()).get();
    print(store.docs);
    setState(() {
      friends = store.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Chat App"),
        actions: [
          PopupMenuButton(
              itemBuilder: (BuildContext bc) => [
                    PopupMenuItem(
                        child: GestureDetector(
                      child: Container(
                          width: double.infinity, child: Text("Log Out")),
                      onTap: () {
                        logOut(context);
                      },
                    )),
                  ],
              onSelected: (route) {
                Inform("ROUTE $route SLECTED");
              })
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection(uid.toString()).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Text('Loading');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new CircularProgressIndicator();
              default:
                return new ListView(
                  children: snapshot.data.docs.map<Widget>((DocumentSnapshot document) {
                    return new Contact(
                      uid: document.data()["uid"],
                      lastMessage: document.data()["lastMessage"],
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingButton(() {
        addContact(context);
      }),
    );
  }
}
