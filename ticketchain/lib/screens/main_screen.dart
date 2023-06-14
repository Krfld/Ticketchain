import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/tabs/home_tab.dart';
import 'package:ticketchain/tabs/profile_tab.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  //todo place in controller
  final index = 1.obs;
  final List tabs = [
    const HomeTab(),
    const ProfileTab()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TicketchainScaffold(
        body: tabs[index.value],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: index.value == 0 ? const Icon(Icons.search_rounded) : const Icon(Icons.settings_rounded),
          onPressed: () {},
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => index.value = 0,
                icon: Icon(
                  Icons.menu_rounded,
                  color: index.value == 0 ? TicketchainColor.purple : TicketchainColor.gray,
                ),
              ),
              // const SizedBox.shrink(),
              IconButton(
                onPressed: () => index.value = 1,
                icon: Icon(
                  Icons.person_rounded,
                  color: index.value == 1 ? TicketchainColor.purple : TicketchainColor.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
