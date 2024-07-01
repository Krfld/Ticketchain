import 'package:flutter/material.dart';

class TicketchainScaffold extends StatelessWidget {
  final Widget body;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const TicketchainScaffold({
    super.key,
    required this.body,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
            body,
          ],
        ),
      ),
    );
  }
}
