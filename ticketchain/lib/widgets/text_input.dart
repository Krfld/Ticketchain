import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final bool autofocus;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const TextInput({
    super.key,
    this.controller,
    this.autofocus = false,
    this.onChanged,
    this.onEditingComplete,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
