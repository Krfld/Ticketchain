import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/controllers/tickets_controller.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/text_input.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class GiftTicketsModal extends GetView<TicketsController> {
  const GiftTicketsModal({super.key});

  Future<bool> _showConfirmGiftModal() async {
    return await showDialog(
          context: Get.context!,
          builder: (context) => AlertDialog(
            title: Text(
                'Gift ${controller.ticketsSelected.length} ticket${controller.ticketsSelected.length != 1 ? 's' : ''}?'),
            content: Text('To ${controller.recipientController.text}'),
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
                      if (await controller.giftTickets()) {
                        Get.find<MainController>().updateControllers();
                        success = true;
                        Get.snackbar(
                          'Success',
                          'Tickets gifted successfully',
                          backgroundColor: TicketchainColor.lightPurple,
                          colorText: TicketchainColor.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Failed to gift tickets',
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
                  success ? Get.close(3) : Get.close(1);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ObxValue(
        (validRecipient) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recipient',
              style: TicketchainTextStyle.heading,
            ),
            const Gap(20),
            TextInput(
              controller: controller.recipientController,
              autofocus: true,
              hintText: 'Address',
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.recipientController.clear();
                  validRecipient(false);
                },
              ),
              onChanged: (value) {
                try {
                  EthereumAddress.fromHex(value);
                  validRecipient(true);
                } catch (_) {
                  validRecipient(false);
                }
              },
            ),
            if (validRecipient()) ...[
              const Gap(20),
              ElevatedButton(
                onPressed: () => _showConfirmGiftModal(),
                child: const Text('Gift'),
              ),
            ],
            const Gap(32),
          ],
        ),
        RegExp(r'^(0x)?[0-9a-f]{40}$', caseSensitive: false)
            .hasMatch(controller.recipientController.text)
            .obs,
      ),
    );
  }
}
