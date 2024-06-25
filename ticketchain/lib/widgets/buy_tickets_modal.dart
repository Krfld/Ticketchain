import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/event_controller.dart';
import 'package:ticketchain/models/package.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class BuyTicketsModal extends GetView<EventController> {
  final PackageModel package;

  const BuyTicketsModal({
    super.key,
    required this.package,
  });

  Future<bool> _showConfirmBuyModal(int amount) async {
    if (amount > package.ticketsAvailable) {
      Get.snackbar(
        'Error',
        'Not enough tickets available',
        backgroundColor: TicketchainColor.lightPurple,
        colorText: TicketchainColor.white,
      );
      return false;
    }

    return await showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            title: Text(
                'Buy $amount ${package.packageConfig.name} ticket${amount != 1 ? 's' : ''}?'),
            content: Text(
                'You will pay ${package.packageConfig.price * amount} wei'),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              FloatingActionButton(
                onPressed: () async => Get.back(result: false),
                backgroundColor: TicketchainColor.red,
                foregroundColor: TicketchainColor.white,
                child: const Icon(
                  Icons.close_rounded,
                  size: 32,
                ),
              ),
              FloatingActionButton(
                onPressed: () async {
                  await Get.showOverlay(
                    asyncFunction: () async {
                      if (await controller.buyTickets(package, amount)) {
                        Get.snackbar(
                          'Success',
                          'Tickets bought successfully',
                          backgroundColor: TicketchainColor.lightPurple,
                          colorText: TicketchainColor.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Failed to buy tickets',
                          backgroundColor: TicketchainColor.lightPurple,
                          colorText: TicketchainColor.white,
                        );
                      }
                    },
                    loadingWidget: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  );
                  Get.back(result: true);
                },
                backgroundColor: TicketchainColor.green,
                foregroundColor: TicketchainColor.white,
                child: const Icon(
                  Icons.check_rounded,
                  size: 32,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(EventController());
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.packageConfig.name,
                  style: TicketchainTextStyle.heading,
                ),
                Text(
                  '${package.packageConfig.price} wei',
                  style: TicketchainTextStyle.subtitle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              package.packageConfig.description,
              style: TicketchainTextStyle.subtitle,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  onPressed: () => controller.amount() != 1
                      ? controller.amount(controller.amount() - 1)
                      : null,
                  child: const Icon(
                    Icons.remove_rounded,
                    size: 24,
                  ),
                ),
                Text(
                  '${controller.amount()}',
                  style: TicketchainTextStyle.heading,
                ),
                FloatingActionButton.small(
                  onPressed: () => controller.amount(controller.amount() + 1),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async =>
                  (await _showConfirmBuyModal(controller.amount()))
                      ? Get.back()
                      : null,
              child: const Center(child: Text('Buy tickets')),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
