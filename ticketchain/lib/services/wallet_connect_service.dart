import 'dart:developer';

import 'package:get/get.dart';
import 'package:ticketchain/modals/wallet_connect_modal.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WalletConnectService extends GetxService {
  late W3MService _w3mService;
  W3MService get w3mService => _w3mService;

  @override
  Future onInit() async {
    super.onInit();

    _w3mService = W3MService(
      projectId: 'fc59cdf6c55dd549b5f43c6d2cf4f10d',
      metadata: const PairingMetadata(
        name: '[Ticketchain name]',
        description: '[Ticketchain description]',
        url: 'https://www.ticketchain.com',
        icons: [''],
        redirect: Redirect(native: 'ticketchain://'),
      ),
    );

    await _w3mService.init();
    await _w3mService.selectChain(W3MChainPresets.chains['137']);

    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionConnectEvent.subscribe(_onSessionConnect);
    _w3mService.onSessionDeleteEvent.subscribe(_onSessionDelete);

    await Future.delayed(1.seconds);
    Get.to(() => const WalletConnectModal());

    await Future.delayed(1.seconds);
    _w3mService.openModal(Get.context!);
  }

  void _onSessionEvent(SessionEvent? args) {
    log('[$runtimeType] _onSessionEvent $args');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    log('[$runtimeType] _onSessionUpdate $args');
  }

  void _onSessionConnect(SessionConnect? args) {
    log('[$runtimeType] _onSessionConnect $args');
  }

  void _onSessionDelete(SessionDelete? args) {
    log('[$runtimeType] _onSessionDelete $args');
  }
}
