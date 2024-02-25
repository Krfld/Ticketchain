import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/pages/profile_settings_page.dart';
import 'package:ticketchain/services/ticketchain_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/search_events_modal.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  Future<void> _showSearchEventsModal() async => await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const SearchEventsModal(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Get.put(MainController());
    return ObxValue(
      (data) => TicketchainScaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                TicketchainService.to.getEvents();
                TicketchainService.to
                    .getPackages('0x91b92a7611E9e014713Ca0F9C7F266e1Cb65A30b');
              },
              child: const Text('Test'),
            ),
            controller.tabs[data()],
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: data() == 0
              ? const Icon(Icons.search_rounded)
              : const Icon(Icons.settings_rounded),
          onPressed: () => data() == 0
              ? _showSearchEventsModal()
              : Get.to(() => const ProfileSettingsPage()),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  controller.changeTabs(0);
                  data(0);
                },
                icon: Icon(
                  Icons.menu_rounded,
                  color: data() == 0
                      ? TicketchainColor.purple
                      : TicketchainColor.gray,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.changeTabs(1);
                  data(1);
                },
                icon: Icon(
                  Icons.person_rounded,
                  color: data() == 1
                      ? TicketchainColor.purple
                      : TicketchainColor.gray,
                ),
              ),
            ],
          ),
        ),
      ),
      RxInt(0),
    );
  }
}
