import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:ntp/ntp.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WCService extends GetxService {
  static WCService get to =>
      Get.isRegistered() ? Get.find() : Get.put(WCService._());
  WCService._();

  final String rpcUrl = 'https://sepolia.base.org';

  late W3MService _w3mService;
  W3MService get w3mService => _w3mService;

  String get address => _w3mService.session!.address!;
  String get chainHexId => _w3mService.selectedChain!.chainHexId;

  @override
  void onInit() {
    W3MChainPresets.testChains.putIfAbsent(
      '84532',
      () => W3MChainInfo(
        chainName: 'Base Sepolia',
        namespace: 'eip155:84532',
        chainId: '84532',
        tokenName: 'ETH',
        rpcUrl: rpcUrl,
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
        icons: [
          'https://img.freepik.com/premium-photo/fire-alphabet-letter-t-isolated-black-background_564276-9267.jpg?w=740'
        ],
        redirect: Redirect(native: 'ticketchain://'),
      ),
    );

    super.onInit();
  }

  Future<bool> authenticate() async {
    await _w3mService.init();
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

      return _w3mService.isConnected;
    } catch (e) {
      log('catch connect $e');
      return false;
    }
  }

  // Future<bool> _switchChain() async {
  //   log(_w3mService.selectedChain.toString());
  //   if (!_w3mService.isConnected || _w3mService.selectedChain == null) {
  //     return false;
  //   }
  //   // if (_w3mService.selectedChain?.namespace ==
  //   //     W3MChainPresets.testChains['84532']!.namespace) return true;
  //   log('switchChain');

  //   try {
  //     _w3mService.launchConnectedWallet();
  //     // await _w3mService.selectChain(W3MChainPresets.testChains['84532']!);
  //     await _w3mService.requestAddChain(W3MChainPresets.testChains['84532']!);
  //     await Future.delayed(2.seconds);

  //     return true;
  //   } catch (e) {
  //     log('catch switchChain $e');
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
      log('catch sign $e');
      return false;
    }
  }

  Future<dynamic> read(
    DeployedContract deployedContract,
    String functionName, [
    List parameters = const [],
  ]) async {
    final output = await _w3mService.requestReadContract(
      deployedContract: deployedContract,
      functionName: functionName,
      parameters: parameters,
    );
    return output.single;
  }

  Future<dynamic> write(
    DeployedContract deployedContract,
    String functionName, {
    List parameters = const [],
    EtherAmount? value,
  }) async {
    _w3mService.launchConnectedWallet();
    final output = await _w3mService.requestWriteContract(
      topic: _w3mService.session!.topic!,
      chainId: W3MChainPresets.testChains['84532']!.namespace,
      deployedContract: deployedContract,
      functionName: functionName,
      parameters: parameters,
      transaction: Transaction(
        value: value,
        from: EthereumAddress.fromHex(_w3mService.session!.address!),
      ),
    );
    return output;
  }

  Future waitForTx(String txHash) async {
    Web3Client client = Web3Client(rpcUrl, Client());
    await Future.doWhile(() async {
      Future.delayed(500.milliseconds);
      return await client.getTransactionReceipt(txHash) == null;
    });
    return (await client.getTransactionReceipt(txHash))!.status;
  }
}
