import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WalletConnectService extends GetxService {
  static WalletConnectService get to =>
      Get.isRegistered() ? Get.find() : Get.put(WalletConnectService._());
  WalletConnectService._();

  late W3MService _w3mService;

  String get address => _w3mService.session!.address!;

  @override
  Future onInit() async {
    super.onInit();

    W3MChainPresets.testChains.putIfAbsent(
      '84532',
      () => W3MChainInfo(
        chainName: 'Base Sepolia',
        namespace: 'eip155:84532',
        chainId: '84532',
        tokenName: 'ETH',
        rpcUrl: 'https://sepolia.base.org',
        blockExplorer: W3MBlockExplorer(
          name: 'Base Explorer',
          url: 'https://sepolia.basescan.org',
        ),
      ),
    );

    _w3mService = W3MService(
      projectId: 'fc59cdf6c55dd549b5f43c6d2cf4f10d',
      metadata: const PairingMetadata(
        name: 'Ticketchain',
        description: 'Ticketchain',
        url: 'https://www.ticketchain.com',
        icons: [''],
        redirect: Redirect(native: 'ticketchain://'),
      ),
    );

    await _w3mService.init();
  }

  Future<bool> authenticate() async {
    return await _connect() && await _sign();
  }

  Future<void> disconnect() async {
    await _w3mService.disconnect();
  }

  Future<bool> _connect() async {
    if (_w3mService.isConnected) return true;
    log('connect');

    try {
      // await _w3mService.disconnect();
      // await Future.delayed(2.seconds);
      await _w3mService.openModal(Get.context!);
      await Future.delayed(2.seconds);

      return true;
    } catch (e) {
      log('connect $e');
      return false;
    }
  }

  // Future<bool> _switchChain() async {
  //   // print(_w3mService.selectedChain?.namespace);
  //   if (!_w3mService.isConnected) return false;
  //   // if (_w3mService.selectedChain?.namespace ==
  //   //     W3MChainPresets.testChains['84532']!.namespace) return true;
  //   log('switchChain');

  //   try {
  //     _w3mService.launchConnectedWallet();
  //     await _w3mService.selectChain(W3MChainPresets.testChains['84532']!);
  //     await _w3mService.requestAddChain(W3MChainPresets.testChains['84532']!);
  //     await Future.delayed(2.seconds);

  //     return true;
  //   } catch (e) {
  //     log('switchChain $e');
  //     return false;
  //   }
  // }

  Future<bool> _sign() async {
    if (!_w3mService.isConnected) return false;
    log('sign');

    await _w3mService.selectChain(W3MChainPresets.testChains['84532']!);

    try {
      String msg =
          sha256.convert(utf8.encode((await NTP.now()).toString())).toString();

      _w3mService.launchConnectedWallet();
      final signature = await _w3mService.request(
        topic: _w3mService.session!.topic!,
        chainId: _w3mService.selectedChain!.namespace,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [msg, _w3mService.session!.address!],
        ),
      );

      final address = EthSigUtil.recoverPersonalSignature(
        signature: signature,
        message: hexToBytes(msg),
      );

      return address.toLowerCase() ==
          _w3mService.session!.address!.toLowerCase();
    } catch (e) {
      log('sign $e');
      return false;
    }
  }

  Future read(DeployedContract deployedContract, String functionName,
      [List? parameters]) async {
    final value = await _w3mService.requestReadContract(
      deployedContract: deployedContract,
      functionName: functionName,
      parameters: parameters ?? [],
    );
    return value.single;
  }

  Future write(DeployedContract deployedContract, String functionName,
      [List? parameters]) async {
    final value = await _w3mService.requestWriteContract(
      topic: _w3mService.session!.topic!,
      chainId: W3MChainPresets
          .testChains['84532']!.namespace, //_w3mService.selectedChain!.chainId,
      deployedContract: deployedContract,
      functionName: functionName,
      transaction: Transaction.callContract(
        contract: deployedContract,
        function: ContractFunction(functionName, []),
        parameters: parameters ?? [],
      ),
    );
    return value;
  }
}
