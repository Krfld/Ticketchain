import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/tabs/home.dart';
import 'package:ticketchain/tabs/profile.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class Body extends StatelessWidget {
  Body({super.key});

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
        floatingActionButton: SizedBox.square(
          dimension: 75,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)),
            elevation: 8,
            child: index.value == 0
                ? const Icon(
                    Icons.search,
                    size: 48,
                    color: TicketchainColor.purple,
                  )
                : const Icon(
                    Icons.settings,
                    size: 48,
                    color: TicketchainColor.purple,
                  ),
            onPressed: () {},
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 8,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => index.value = 0,
                icon: Icon(
                  Icons.menu,
                  size: 48,
                  color: index.value == 0 ? TicketchainColor.purple : TicketchainColor.gray,
                ),
              ),
              // const SizedBox.shrink(),
              IconButton(
                onPressed: () => index.value = 1,
                icon: Icon(
                  Icons.person,
                  size: 48,
                  color: index.value == 1 ? TicketchainColor.purple : TicketchainColor.gray,
                ),
              ),
            ],
          ),
          // showSelectedLabels: false,
          // showUnselectedLabels: false,
          // elevation: 8,
          // currentIndex: index.value,
          // onTap: (value) => index.value = value,
          // items: const [
          //   BottomNavigationBarItem(
          //     label: 'Home',
          //     icon: Icon(
          //       Icons.menu,
          //       size: 48,
          //     ),
          //   ),
          //   BottomNavigationBarItem(
          //     label: 'Profile',
          //     icon: Icon(
          //       Icons.person,
          //       size: 48,
          //     ),
          //   ),
          // ],
        ),
      ),
    );
  }
}
