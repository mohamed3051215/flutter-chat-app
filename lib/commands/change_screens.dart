import "package:flutter/material.dart";

changeScreen(BuildContext context, Widget wantedScreen) {
  return Navigator.push(
      context, MaterialPageRoute(builder: (context) => wantedScreen));
}

changeScreenReplacement(BuildContext context, Widget wantedScreen) {
  return Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => wantedScreen));
}

popScreen(
  BuildContext context,
) {
  return Navigator.pop(context);
}
