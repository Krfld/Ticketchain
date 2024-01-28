import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/widgets/event_card.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Obx(
      () => Wrap(
        runSpacing: 20,
        children:
            controller.events.map((event) => EventCard(event: event)).toList(),
      ),
    );
  }
}
