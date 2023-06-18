import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/widgets/event_card.dart';

class HomeTab extends GetView<MainController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          for (EventModel event in controller.events) ...[
            EventCard(event: event),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
    // ListView.separated(
    //   itemCount: 9,
    //   separatorBuilder: (context, index) => const SizedBox(height: 20),
    //   itemBuilder: (context, index) => const TicketchainCard(),
    // );
  }
}
