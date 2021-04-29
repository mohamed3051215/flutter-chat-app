import 'package:chat_app/commands/change_screens.dart';
import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";

class SearchTile extends StatefulWidget {
  final String name, uid;

  const SearchTile({Key key, this.name, this.uid}) : super(key: key);

  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {
  String imageUrl;
  setData() async {
    await Firebase.initializeApp();
    var _operation = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get();
    var _imageUrl = _operation.data()["imageUrl"];
    setState(() {
      imageUrl = _imageUrl;
    });
  }

  @override
  void initState() {
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            widget.name,
            style: TextStyle(fontSize: 20),
          ),
          leading: CircleAvatar(
            radius: 30.0,
            backgroundImage: imageUrl == null
                ? AssetImage("assets/images/loading.png")
                : NetworkImage(imageUrl),
            backgroundColor: Colors.transparent,
          ),
          onTap: () {
            Inform(widget.uid);
            changeScreenReplacement(context, ChatRoomScreen(widget.uid));
          },
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
