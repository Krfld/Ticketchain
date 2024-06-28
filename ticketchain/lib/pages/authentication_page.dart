import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TicketchainScaffold(
      body: Center(
        child: Obx(
          () => WCService.to.connectionStatus().isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const Gap(8),
                    Text(
                      WCService.to.connectionStatus(),
                      style: TicketchainTextStyle.title
                          .copyWith(color: TicketchainColor.lightPurple),
                    ),
                  ],
                )
              : FloatingActionButton.extended(
                  icon: const Icon(Icons.wallet_rounded),
                  label: const Text(
                    'Connect Wallet',
                    style: TicketchainTextStyle.title,
                  ),
                  onPressed: () => WCService.to.authenticate(),
                ),
        ),
      ),
    );
  }
}
