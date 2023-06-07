import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/tabs/home.dart';
import 'package:ticketchain/tabs/profile.dart';
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index.value,
          onTap: (value) => index.value = value,
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.menu),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
