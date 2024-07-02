import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/validator/validator_controller.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class ValidatorPage extends GetView<ValidatorController> {
  const ValidatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ValidatorController());
    return TicketchainScaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Address:',
                    style: TicketchainTextStyle.title
                        .copyWith(color: TicketchainColor.white),
                  ),
                ),
                Text(
                  Web3Service.to.wallet.privateKey.address.hex,
                  style: TicketchainTextStyle.text,
                ),
                const Gap(8),
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: const Text('Show Address QR Code'),
                ),
              ],
            ),
            FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('Validate Tickets'),
            ),
            // QrImageView(
            //   data: Web3Service.to.wallet.privateKey.address.hex,
            // ),
          ],
        ),
      ),
    );
  }
}
