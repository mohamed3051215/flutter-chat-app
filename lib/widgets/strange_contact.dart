import 'package:chat_app/commands/change_screens.dart';
import 'package:chat_app/screens/chat_room.dart';
import "package:flutter/material.dart";

class StrangeContact extends StatelessWidget {
  final name;
  // final String imageUrl;

  const StrangeContact({Key key, this.name}) : super(key: key);
  goChatScreen(BuildContext context) {
    changeScreenReplacement(context, ChatRoomScreen(name["uid"]));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            title: Text(name["name"]),
            onTap: () {
              goChatScreen(context);
            },
            subtitle: Text(name["email"]),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                name["imageUrl"],
                width: 50,
                fit: BoxFit.cover,
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
