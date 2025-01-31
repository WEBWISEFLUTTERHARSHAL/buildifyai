import 'package:Buildify_AI/utils/colors.dart';
import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final Color bgColor;
  GeneralButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.bgColor = darkBlueTheme});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: bgColor,
        minimumSize: Size(
          double.infinity,
          52,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: text == ""
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                backgroundColor: grey,
                color: white,
                strokeCap: StrokeCap.round,
                strokeWidth: 3,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
