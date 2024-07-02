import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class QrCodeModal extends StatelessWidget {
  final String title;
  final String data;
  final List<Widget>? actions;

  const QrCodeModal({
    super.key,
    required this.title,
    required this.data,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TicketchainTextStyle.title,
      ),
      content: SizedBox(
        width: Get.size.width,
        child: QrImageView(
          data: data,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: actions,
    );
  }
}
