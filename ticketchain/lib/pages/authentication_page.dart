import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class AuthenticationPage extends GetView<AuthenticationController> {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationController.to;
    return TicketchainScaffold(
      scrollable: false,
      body: ObxValue(
        (loading) => loading()
            ? const CircularProgressIndicator()
            : FloatingActionButton.extended(
                label: const Text(
                  'Connect Wallet',
                  style: TicketchainTextStyle.title,
                ),
                icon: const Icon(Icons.login_rounded),
                onPressed: () async {
                  loading.value = true;
                  await controller.signIn();
                  loading.value = false;
                },
              ),
        false.obs,
      ),
    );
  }
}
