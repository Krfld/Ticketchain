import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/avatar.dart';
import 'package:ticketchain/widgets/text_input.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class ProfileSettingsPage extends GetView<ProfileController> {
  const ProfileSettingsPage({super.key});

  Future<bool> saveChangesModal() async => await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('Save changes?'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            FloatingActionButton(
              onPressed: () async => Get.back(result: true),
              backgroundColor: TicketchainColor.red,
              foregroundColor: TicketchainColor.white,
              child: const Icon(
                Icons.close_rounded,
                size: 32,
              ),
            ),
            FloatingActionButton(
              onPressed: () async {
                await Get.showOverlay(
                  asyncFunction: controller.saveChanges,
                  loadingWidget: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                );
                Get.back(result: true);
              },
              backgroundColor: TicketchainColor.green,
              foregroundColor: TicketchainColor.white,
              child: const Icon(
                Icons.check_rounded,
                size: 32,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    controller.nameController.text = controller.user.name;
    return WillPopScope(
      onWillPop: () async => controller.hasChanges ? await saveChangesModal() : true,
      child: TicketchainScaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async => controller.hasChanges
              ? await saveChangesModal()
                  ? Get.back()
                  : null
              : Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 32,
          ),
        ),
        body: Obx(
          () => Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              Avatar(
                url: controller.user.avatarUrl,
                onIconPressed: () async => await Get.showOverlay(
                  asyncFunction: controller.changeAvatar,
                  loadingWidget: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
              TextInput(
                controller: controller.nameController,
                hintText: 'Name',
                icon: const Icon(Icons.abc_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
