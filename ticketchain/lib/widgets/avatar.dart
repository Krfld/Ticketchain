import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';

class Avatar extends StatelessWidget {
  final String url;
  final Function()? onIconPressed;

  const Avatar({
    super.key,
    required this.url,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Material(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: CircleAvatar(
            radius: 75,
            backgroundImage: NetworkImage(url),
          ),
        ),
        if (onIconPressed != null)
          IconButton(
            iconSize: 24,
            icon: const Icon(Icons.edit_rounded),
            onPressed: onIconPressed,
          )
      ],
    );
  }
}
