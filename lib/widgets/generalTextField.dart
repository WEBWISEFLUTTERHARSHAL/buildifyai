import 'package:Buildify_AI/utils/colors.dart';
import 'package:flutter/material.dart';

class GeneralTextField extends StatelessWidget {
  String hintText;
  int maxLines;
  TextEditingController? controller = TextEditingController();
  GeneralTextField({
    super.key,
    this.maxLines = 4,
    this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: darkBlueTheme,
      maxLines: maxLines,
      cursorRadius: Radius.circular(20),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFC3C3C3),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
