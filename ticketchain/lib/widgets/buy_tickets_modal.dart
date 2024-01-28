import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/event_controller.dart';
import 'package:ticketchain/models/package_model.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class BuyTicketsModal extends GetView<EventController> {
  final PackageModel package;

  const BuyTicketsModal({
    super.key,
    required this.package,
  });

  Future<bool> _showConfirmBuyModal(int amount) async =>
      await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text(
              'Buy $amount ${package.name} ticket${amount != 1 ? 's' : ''}?'),
          content: Text('You will pay ${package.price * amount}€'),
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
                  asyncFunction: () async =>
                      await controller.buyTickets(package, amount),
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
                  package.name,
                  style: TicketchainTextStyle.heading,
                ),
                Text(
                  '${package.price}€',
                  style: TicketchainTextStyle.subtitle,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              package.description,
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
