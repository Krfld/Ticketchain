import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/avatar.dart';
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
        Avatar(url: controller.avatar),
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
