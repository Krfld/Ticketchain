import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/main/controllers/home_controller.dart';
import 'package:ticketchain/pages/main/controllers/main_controller.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/loading_modal.dart';
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

  Future<void> _showConfirmDisconnectModal() async => await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('Disconnect wallet?'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            FloatingActionButton(
              onPressed: () => Get.back(),
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
                  asyncFunction: () async => await WCService.to.disconnect(),
                  loadingWidget: const LoadingModal(),
                );
                Get.back();
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
    Get.put(MainController());
    return ObxValue(
      (tab) => TicketchainScaffold(
        body: controller.tabs[tab()],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: tab() == 0
            ? FloatingActionButton(
                child: Icon(Get.find<HomeController>().filter.isEmpty
                    ? Icons.search_rounded
                    : Icons.youtube_searched_for_rounded),
                onPressed: () => _showSearchEventsModal(),
              )
            : FloatingActionButton(
                child: const Icon(Icons.logout_rounded),
                onPressed: () => _showConfirmDisconnectModal(),
              ),
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
