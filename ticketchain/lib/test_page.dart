import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class TestPage extends GetView<WalletConnectService> {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WalletConnectService());
    return TicketchainScaffold(
      scrollable: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async =>
                log((await controller.authenticate()).toString()),
            child: const Text('Connect Wallet'),
          ),
        ],
      ),
    );
  }
}
