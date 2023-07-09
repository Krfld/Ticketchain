import 'package:flutter/material.dart';

class TicketchainScaffold extends StatelessWidget {
  final Widget? body;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool scrollable;

  const TicketchainScaffold({
    super.key,
    this.body,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.scrollable = true,
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
            scrollable
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: body,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: body,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
