import 'package:chat_app/commands/inform.dart';
import 'package:chat_app/widgets/chat_room_app_bar.dart';
import 'package:chat_app/widgets/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final uid;
  ChatRoomScreen(this.uid);
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  String name;
  String imageUrl;
  String _uid = FirebaseAuth.instance.currentUser.uid;
  TextEditingController m = TextEditingController();
  @override
  void initState() {
    setData();
    super.initState();
  }

  bool validate = false;
  setData() async {
    try {
      var _operation = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();
      var _name = _operation.data()["name"];
      var _userid = FirebaseAuth.instance.currentUser.uid;
      setState(() {
        name = _name;
        _uid = _userid;
        imageUrl = _operation.data()["imageUrl"];
      });
    } catch (error) {
      print(error);
    }
  }

  sendMessage(BuildContext context) async {
    try {
      var text = m.text;
      m.clear();
      String __name;
      var _oper =
          await FirebaseFirestore.instance.collection("users").doc(_uid).get();
      __name = _oper.data()["name"];
      var data = {
        "name": __name,
        "message": text,
        "uid": _uid.toString(),
        "dateHours":
            "${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}",
        "dateDays":
            "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
        "createdTime": Timestamp.now(),
      };
      await Firebase.initializeApp();
      await FirebaseFirestore.instance
          .collection(_uid)
          .doc(widget.uid)
          .collection("messages")
          .doc()
          .set(data);
      await FirebaseFirestore.instance
          .collection(_uid)
          .doc(widget.uid)
          .set({"lastMessage": null, "uid": widget.uid});
      Inform("Message set successfully");
      await FirebaseFirestore.instance
          .collection(widget.uid)
          .doc(_uid)
          .set({"uid": _uid, "lastMessage": null});
      await FirebaseFirestore.instance
          .collection(widget.uid)
          .doc(_uid)
          .collection("messages")
          .add(data);
      await FirebaseFirestore.instance
          .collection(widget.uid)
          .doc(_uid)
          .update({"uid": _uid});
      await FirebaseFirestore.instance
          .collection(widget.uid)
          .doc(_uid)
          .update({"lastMessage": text});
      await FirebaseFirestore.instance
          .collection(_uid)
          .doc(widget.uid)
          .update({"lastMessage": text});
    } catch (error) {
      Warn(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ChatAppBar(
          name: name,
          imageUrl: imageUrl,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 160,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(_uid)
                      .doc(widget.uid.toString())
                      .collection("messages")
                      .orderBy("createdTime", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Container(
                            width: 60, height: 60, child: Text("Loading ...")),
                      );
                    else
                      return Container(
                        child: ListView(
                            shrinkWrap: true,
                            children:
                                snapshot.data.docs.map<Widget>((document) {
                              return new Message(
                                message: document.data()["message"],
                                name: document.data()["name"],
                                dateHours: document.data()["dateHours"],
                                dateDays: document.data()["dateDays"],
                                uid: document.data()["uid"],
                                createdTime: document.data()["createdTime"],
                              );
                            }).toList()),
                      );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 75,
                    height: 60,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 5.0,
                        minWidth: 5.0,
                        maxHeight: 90.0,
                        maxWidth: 30.0,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: m,
                        decoration: InputDecoration(
                            hintText: "Send Message...",
                            enabledBorder: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder()),
                        style: TextStyle(fontSize: 20),
                        onChanged: (text) {
                          setState(() {
                            if (text == '') {
                              setState(() {
                                validate = false;
                              });
                            } else {
                              setState(() {
                                validate = true;
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    color: !validate ? Colors.grey : Colors.blue,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (validate) sendMessage(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
