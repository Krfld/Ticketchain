import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticket_card.dart';

class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        Material(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const CircleAvatar(
            radius: 75,
            backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/a/AAcHTtdzvSpzCYbB0Y9WWKu21M2hQ2xy8FanVcheKEKBeg=s360-c-no',
            ),
          ),
        ),
        const Text(
          'Rodrigo Dias',
          style: TicketchainTextStyle.name,
        ),
        TicketCard(ticket: TicketModel()),
        TicketCard(ticket: TicketModel()),
        TicketCard(ticket: TicketModel()),
        TicketCard(ticket: TicketModel()),
        TicketCard(ticket: TicketModel()),
      ],
    );
  }
}
