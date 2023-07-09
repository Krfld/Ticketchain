import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String url;

  const Avatar({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      child: CircleAvatar(
        radius: 75,
        backgroundImage: NetworkImage(url),
      ),
    );
  }
}
