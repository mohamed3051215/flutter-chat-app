import 'package:chat_app/widgets/my_contact.dart';
import 'package:chat_app/widgets/search_tile.dart';
import 'package:chat_app/widgets/strange_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:search_page/search_page.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  Map<String, String> names = {};
  List<String> emails = [];
  String uid;
  showError(BuildContext context, error) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
          title: Text("Search Error"), content: Text(error.toString())),
    );
  }

  setResult() async {
    await Firebase.initializeApp();

    var snapshot = await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      names[snapshot.docs[i].get("name")] = snapshot.docs[i].get("uid");
    }
    String _uid = FirebaseAuth.instance.currentUser.uid.toString();
    var username =
        await FirebaseFirestore.instance.collection("users").doc(_uid).get();
    names.remove(username.data()["name"]);
    setState(() {
      uid = _uid;
    });
    print(names);
    for (String item in names.keys) {
      emails.add(item);
    }
  }

  @override
  void initState() {
    super.initState();
    setResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchPage(
                      builder: (hello) {
                        return SearchTile(name: hello, uid: names[hello]);
                      },
                      filter: (person) => [person],
                      items: emails));
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Text('Loading');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new CircularProgressIndicator();
              default:
                return new ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    if (!snapshot.hasData)
                      return CircularProgressIndicator();
                    else {
                      if (uid != null) if (uid != document.data()["uid"])
                        return new StrangeContact(
                          name: document,
                        );
                      else
                        return MyContact(name: document);
                    }
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }
}
