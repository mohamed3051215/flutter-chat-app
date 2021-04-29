import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    Key key,
    @required this.imageUrl,
    @required this.name,
  }) : super(key: key);

  final String imageUrl;
  final String name;

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              '$imageUrl',
              fit: BoxFit.contain,
              height: 32,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(name == null ? "loading" : name))
        ],
      ),
    );
  }
}
