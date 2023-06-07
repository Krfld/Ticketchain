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
        floatingActionButton: SizedBox(
          height: 75,
          width: 75,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)),
            elevation: 8,
            child: const Icon(
              Icons.search,
              size: 48,
              color: TicketchainColor.purple,
            ),
            onPressed: () {},
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 8,
          currentIndex: index.value,
          onTap: (value) => index.value = value,
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(
                Icons.menu,
                size: 48,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(
                Icons.person,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
