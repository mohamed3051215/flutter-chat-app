import "package:flutter/material.dart";

class MyContact extends StatelessWidget {
  final name;
  // final String imageUrl;

  const MyContact({Key key, this.name}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
          child: ListTile(
            title: Text(name["name"]),
            onTap: () {},
            subtitle: Text(name["email"]),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
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
