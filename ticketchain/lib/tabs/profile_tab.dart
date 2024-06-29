import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/pages/tickets_page.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ProfileTab extends GetView<ProfileController> {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Obx(
        () => Wrap(
          spacing: 1000,
          runSpacing: 20,
          children: [
            Text(
              'Profile',
              style: TicketchainTextStyle.heading
                  .copyWith(color: TicketchainColor.white),
            ),
            W3MAccountButton(service: WCService.to.w3mService),
            if (controller.tickets.isEmpty)
              Text(
                controller.loading
                    ? 'Loading tickets...'
                    : 'You have no tickets',
                style: TicketchainTextStyle.text,
              ),
            ...controller.tickets.entries.map(
              (ticketsEntry) => TicketchainCard(
                title: ticketsEntry.key.eventConfig.name,
                subtitle: 'You have ${ticketsEntry.value.length} tickets',
                leading: const Icon(Icons.festival_rounded),
                onTap: () => Get.to(
                  () => TicketsPage(
                    event: ticketsEntry.key,
                    tickets: ticketsEntry.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
