import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
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
      (tab) => TicketchainScaffold(
        body: controller.tabs[tab()],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: tab() == 0
            ? FloatingActionButton(
                child: const Icon(Icons.search_rounded),
                onPressed: () => _showSearchEventsModal(),
              )
            : null,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  controller.updateControllers();
                  tab(0);
                },
                icon: Icon(
                  Icons.menu_rounded,
                  color: tab() == 0
                      ? TicketchainColor.purple
                      : TicketchainColor.gray,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.updateControllers();
                  tab(1);
                },
                icon: Icon(
                  Icons.person_rounded,
                  color: tab() == 1
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
