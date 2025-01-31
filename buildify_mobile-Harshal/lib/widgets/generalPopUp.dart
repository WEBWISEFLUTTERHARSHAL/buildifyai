import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:flutter/material.dart';

class GeneralPopUp extends StatelessWidget {
  String? title;
  String? message;
  GeneralPopUp({
    super.key,
    this.title = strings.error,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!),
      content: Text(
        message == null || message!.isEmpty || message == "null"
            ? strings.genericError
            : message!,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      backgroundColor: popUpDialog,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: darkBlueTheme,
            foregroundColor: white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(strings.ok),
        ),
      ],
    );
  }
}
