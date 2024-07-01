import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/event/event_controller.dart';
import 'package:ticketchain/pages/main/controllers/main_controller.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/loading_modal.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class BuyTicketsModal extends GetView<EventController> {
  final EventModel event;
  final int packageId;

  const BuyTicketsModal({
    super.key,
    required this.event,
    required this.packageId,
  });

  PackageModel get package => event.packages[packageId];

  Future<bool> _showConfirmBuyModal(int amount) async {
    if (amount > event.ticketsAvailable(packageId).length) {
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
                'You will pay ${package.packageConfig.price.getValueInUnit(EtherUnit.ether) * amount} eth'),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              FloatingActionButton(
                onPressed: () => Get.back(result: false),
                backgroundColor: TicketchainColor.red,
                foregroundColor: TicketchainColor.white,
                child: const Icon(
                  Icons.close_rounded,
                  size: 32,
                ),
              ),
              FloatingActionButton(
                onPressed: () async {
                  bool success = false;
                  await Get.showOverlay(
                    asyncFunction: () async {
                      if (await controller.buyTickets(
                          event, packageId, amount)) {
                        Get.find<MainController>().updateControllers();
                        success = true;
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
                    loadingWidget: const LoadingModal(),
                  );
                  Get.close(success ? 3 : 1);
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
                  '${package.packageConfig.price.getValueInUnit(EtherUnit.ether)} eth',
                  style: TicketchainTextStyle.subtitle,
                ),
              ],
            ),
            const Gap(20),
            Text(
              package.packageConfig.description,
              style: TicketchainTextStyle.subtitle,
            ),
            const Gap(20),
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
            const Gap(20),
            ElevatedButton(
              onPressed: () async =>
                  (await _showConfirmBuyModal(controller.amount()))
                      ? Get.back()
                      : null,
              child: const Text('Buy'),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}
