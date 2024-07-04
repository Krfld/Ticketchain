import 'dart:developer';

import 'package:get/get.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WCService extends GetxService {
  static WCService get to =>
      Get.isRegistered() ? Get.find() : Get.put(WCService._());
  WCService._();

  RxBool isAuthenticated = false.obs;
  RxString connectionStatus = ''.obs;

  late W3MService _w3mService;
  W3MService get w3mService => _w3mService;

  String get address => _w3mService.session!.address!;
  W3MChainInfo get targetChain => W3MChainPresets.testChains['84532']!;

  @override
  void onInit() {
    W3MChainPresets.testChains.putIfAbsent(
      '84532',
      () => W3MChainInfo(
        chainName: 'Base Sepolia Testnet',
        namespace: 'eip155:84532',
        chainId: '84532',
        tokenName: 'ETH',
        rpcUrl:
            'https://base-sepolia.g.alchemy.com/v2/xXtfF_qzcGw5k0BaNIwqF0YokA1lWyb_', //'https://sepolia.base.org',
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

    _w3mService.onModalDisconnect.subscribe((_) => isAuthenticated(false));

    super.onInit();
  }

  Future<void> authenticate() async {
    connectionStatus('Authenticating...');
    await _w3mService.init();
    isAuthenticated(await _connect());
    connectionStatus('');
  }

  Future<bool> _connect() async {
    if (_w3mService.isConnected) return true;

    log('connect');
    connectionStatus('Connect wallet');

    try {
      await Future.delayed(1.seconds);
      await _w3mService.openModal(Get.context!);

      return _w3mService.isConnected;
    } catch (e) {
      log('catch connect: $e');
      return false;
    }
  }

  // Future<bool> _switchChain() async {
  //   log(_w3mService.selectedChain?.namespace ?? 'null');

  //   log(_w3mService.getApprovedChains().toString());
  //   log(_w3mService.getAvailableChains().toString());
  //   // MethodsConstants.
  //   return true;
  //   log('switchChain');
  //   connectionStatus('Switch chain');

  //   try {
  //     await Future.delayed(1.seconds);
  //     _w3mService.launchConnectedWallet();
  //     await _w3mService.requestAddChain(targetChain);

  //     return true;
  //   } catch (e) {
  //     log('catch switchChain: $e');
  //     return false;
  //   }
  // }

  // Future<bool> _sign() async {
  //   if (!_w3mService.isConnected) return false;

  //   log('sign');
  //   connectionStatus('Sign message');

  //   try {
  //     String message = 'Connect to Ticketchain';

  //     String signature = await signMessage(message);

  //     String recoveredAddress = EthSigUtil.recoverPersonalSignature(
  //       signature: signature,
  //       message: utf8.encode(message),
  //     );

  //     return recoveredAddress.toLowerCase() ==
  //         _w3mService.session!.address!.toLowerCase();
  //   } catch (e) {
  //     log('catch sign: $e');
  //     return false;
  //   }
  // }

  Future<String> signMessage(String message) async {
    await Future.delayed(1.seconds);
    _w3mService.launchConnectedWallet();
    final signature = await _w3mService.request(
      topic: _w3mService.session!.topic!,
      chainId: targetChain.namespace,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [message, _w3mService.session!.address!],
      ),
    );

    return signature;
  }

  Future<dynamic> read(
    DeployedContract deployedContract,
    String functionName, [
    List parameters = const [],
  ]) async {
    // await _w3mService.selectChain(targetChain);
    // final output = await _w3mService.requestReadContract(
    //   deployedContract: deployedContract,
    //   functionName: functionName,
    //   parameters: parameters,
    // );
    List output = await Web3Service.to.read(
      deployedContract,
      deployedContract.function(functionName),
      parameters,
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
      chainId: targetChain.namespace,
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
}
