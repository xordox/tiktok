import 'package:flutter/material.dart';
import 'package:tiktok/constatns.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String labelText;
  final bool isObscure;
  final IconData icon;

  const TextInputField(Key? key, this.textEditingController, this.labelText, this.isObscure, this.icon): super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: labelText,
        prefix: Icon(icon),
        labelStyle: const TextStyle(fontSize: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
      ),
      obscureText: isObscure,
    );
  }
}