import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainController());
    return ObxValue(
      (data) => TicketchainScaffold(
        body: controller.tabs[data()],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: data() == 0 ? const Icon(Icons.search_rounded) : const Icon(Icons.settings_rounded),
          onPressed: () {},
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => data(0),
                icon: Icon(
                  Icons.menu_rounded,
                  color: data() == 0 ? TicketchainColor.purple : TicketchainColor.gray,
                ),
              ),
              IconButton(
                onPressed: () => data(1),
                icon: Icon(
                  Icons.person_rounded,
                  color: data() == 1 ? TicketchainColor.purple : TicketchainColor.gray,
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
