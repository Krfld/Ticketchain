import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final String? hintText;
  final bool autofocus;

  const TextInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.hintText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
        ),
      ),
    );
  }
}
