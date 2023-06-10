import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/tabs/home.dart';
import 'package:ticketchain/tabs/profile.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class Body extends StatelessWidget {
  Body({super.key});

  //todo place in controller
  final index = 0.obs;
  final List tabs = [
    const Home(),
    const Profile()
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
