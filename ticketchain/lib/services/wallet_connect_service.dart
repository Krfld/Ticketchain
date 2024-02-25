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

  final String _rpcUrl =
      'https://polygon-mumbai.g.alchemy.com/v2/qTpogxSbn9cBPtkOxyLuW97wGvnPitZp';

  @override
  Future onInit() async {
    super.onInit();

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
    await _w3mService.disconnect();
  }

  Future read(DeployedContract deployedContract, String functionName,
      [List? parameters]) async {
    return await _w3mService.requestReadContract(
      deployedContract: deployedContract,
      functionName: functionName,
      rpcUrl: _rpcUrl,
      parameters: parameters ?? [],
    );
  }

  Future write(DeployedContract deployedContract, String functionName,
      [List? parameters]) async {
    return await _w3mService.requestWriteContract(
      topic: _w3mService.session!.topic!,
      chainId: _w3mService.selectedChain!.chainId,
      rpcUrl: _rpcUrl,
      deployedContract: deployedContract,
      functionName: functionName,
      transaction: Transaction.callContract(
        contract: deployedContract,
        function: ContractFunction(functionName, []),
        parameters: parameters ?? [],
      ),
    );
  }

  Future<bool> authenticate() async {
    await _connect();
    await Future.delayed(1.seconds);
    return await _sign();
  }

  Future<void> _connect() async {
    await _w3mService.disconnect();
    await _w3mService.openModal(Get.context!);
  }

  Future<bool> _sign() async {
    if (!_w3mService.isConnected) return false;

    try {
      String msg =
          sha256.convert(utf8.encode((await NTP.now()).toString())).toString();

      _w3mService.launchConnectedWallet();
      final signature = await _w3mService.web3App!.request(
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
      log(e.toString());
      return false;
    }
  }
}
