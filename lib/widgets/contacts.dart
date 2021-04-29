import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class Contact extends StatefulWidget {
  final String uid, lastMessage;

  const Contact({Key key, this.uid, this.lastMessage}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  String name;
  String contactId, lastMessage;
  @override
  void initState() {
    _setData();
    super.initState();
  }

  _setData() async {
    try {
      var _contactId = widget.uid;
      var _lastMesssage = widget.lastMessage;
      var _oper = await FirebaseFirestore.instance
          .collection("users")
          .doc(_contactId)
          .get();
      var _name = await _oper.data()["name"];
      setState(() {
        name = _name;
        contactId = _contactId;
        lastMessage = _lastMesssage.toString();
      });
    } catch (error) {
      Warn(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            title: Text(name == null ? "loading" : name),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(contactId)));
            },
            subtitle: Text(
                widget.lastMessage == 'null' || widget.lastMessage == null
                    ? "New Contact"
                    : widget.lastMessage),
            leading: SizedBox(
              child: ClipRRect(
                child: Image.network(
                  "https://cdn.arstechnica.net/wp-content/uploads/2016/02/5718897981_10faa45ac3_b-640x624.jpg",
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
