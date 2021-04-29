import "package:flutter/material.dart";

showError(BuildContext context, String error) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Error"),
      content: Text(error),
    ),
  );
} 
