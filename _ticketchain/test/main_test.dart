import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

void main() {
  test('WC Test', () async {
    const String rpcUrl = 'https://sepolia.base.org';

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

    W3MService w3mService = W3MService(
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

    await w3mService.init();
    print(w3mService.session!.topic);
    print(w3mService.session!.pairingTopic);

    String address = '0xe53b00c08979af2374a7df886539e0ad79d8cccb';
    String msg =
        bytesToHex(utf8.encode('Validate tickets')); // at ${DateTime.now()}

    final signature = await w3mService.web3App!.request(
      topic: '700d0a9d6a4a93d4b7cf3c8cf5abe996583a254b52053ff995f81215560f966c',
      chainId: W3MChainPresets.testChains['84532']!.namespace,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [msg, address],
      ),
    );

    final recoveredAddress = EthSigUtil.recoverPersonalSignature(
      signature: signature,
      message: hexToBytes(msg),
    );

    print(recoveredAddress.toLowerCase() == address.toLowerCase());
  });
}
