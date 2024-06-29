import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/event_card.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Obx(
        () => Wrap(
          spacing: 1000,
          runSpacing: 20,
          children: [
            Text(
              'Events',
              style: TicketchainTextStyle.heading
                  .copyWith(color: TicketchainColor.white),
            ),
            if (controller.events.isEmpty)
              Text(
                controller.loading ? 'Loading events...' : 'No events found',
                style: TicketchainTextStyle.text,
              ),
            ...controller.events
                .map((event) => EventCard(event: event))
                .toList(),
          ],
        ),
      ),
    );
  }
}
