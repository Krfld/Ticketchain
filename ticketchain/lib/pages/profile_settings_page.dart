import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_settings_controller.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/avatar.dart';
import 'package:ticketchain/widgets/text_input.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class ProfileSettingsPage extends GetView<ProfileSettingsController> {
  const ProfileSettingsPage({super.key});

  Future<bool> _showSaveChangesModal() async =>
      await showDialog(
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
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileSettingsController());
    return WillPopScope(
      onWillPop: () async =>
          true, //controller.hasChanges ? await _showSaveChangesModal() : true,
      child: TicketchainScaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async => true // controller.hasChanges
              ? await _showSaveChangesModal()
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
                url: '',
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
                prefixIcon: const Icon(Icons.abc_rounded),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: TicketchainColor.red,
                ),
                label: Text(
                  'Log out',
                  style: TicketchainTextStyle.title
                      .copyWith(color: TicketchainColor.red),
                ),
                onPressed: () => controller.logOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
