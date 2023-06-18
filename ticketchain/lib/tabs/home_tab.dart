import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/widgets/event_card.dart';

class HomeTab extends GetView<MainController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 20,
        children: controller.events.map((element) => EventCard(event: element)).toList(),
      ),
    );
  }
}
