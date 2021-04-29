import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final Function func;
  FloatingButton(this.func);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).primaryColor),
        child: IconButton(icon: Icon(Icons.add), onPressed: func));
  }
}
