import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class SearchEventsModal extends GetView<HomeController> {
  const SearchEventsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Search',
            style: TicketchainTextStyle.heading,
          ),
          const SizedBox(height: 16),
          Card(
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.filterEvents(value),
              onEditingComplete: () => Get.back(),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Event',
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
