import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/main/controllers/home_controller.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/text_input.dart';

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
          const Gap(20),
          TextInput(
            controller: controller.searchController,
            autofocus: true,
            onChanged: (value) => controller.filter(value),
            onEditingComplete: () => Get.back(),
            hintText: 'Event',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => controller.clearFilter(),
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
