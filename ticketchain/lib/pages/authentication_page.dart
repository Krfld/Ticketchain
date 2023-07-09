import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticationService = Get.put(AuthenticationService());
    return TicketchainScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'Sign in with Google',
          style: TicketchainTextStyle.title,
        ),
        icon: const Icon(Icons.login_rounded),
        onPressed: () => authenticationService.signIn(),
      ),
    );
  }
}
