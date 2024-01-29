import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WalletConnectModal extends GetView<WalletConnectService> {
  const WalletConnectModal({super.key});

  @override
  Widget build(BuildContext context) {
    return TicketchainScaffold(
      scrollable: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: !controller.w3mService.isConnected
            ? [
                W3MNetworkSelectButton(service: controller.w3mService),
                W3MConnectWalletButton(service: controller.w3mService),
              ]
            : [
                W3MAccountButton(service: controller.w3mService),
              ],
      ),
    );
  }
}
