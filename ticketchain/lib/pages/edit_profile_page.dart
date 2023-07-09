import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/widgets/avatar.dart';
import 'package:ticketchain/widgets/text_input.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TicketchainScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 32,
        ),
      ),
      body: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 20,
        children: [
          Avatar(url: controller.avatar),
          const TextInput(
            // controller: controller.nameController,
            // onChanged: (value) => null,
            // onEditingComplete: () => Get.back(),
            hintText: 'Name',
          ),
        ],
      ),
    );
  }
}
