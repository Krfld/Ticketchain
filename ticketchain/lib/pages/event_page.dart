import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class EventPage extends GetView<HomeController> {
  final EventModel event;

  const EventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return TicketchainScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 32,
        ),
      ),
      body: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Text(
            event.name,
            style: TicketchainTextStyle.name,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${event.date.day}/${event.date.month}/${event.date.year}',
                style: TicketchainTextStyle.text,
              ),
              const Text(
                'x packages',
                style: TicketchainTextStyle.text,
              ),
            ],
          ),
          TextButton.icon(
            label: Text(event.location),
            icon: const Icon(Icons.place_rounded),
            onPressed: () async => await MapsLauncher.launchQuery(event.location),
          ),
          Wrap(
            runSpacing: 20,
            children: [
              Text(
                event.description,
                style: TicketchainTextStyle.text,
              ),
              ...event.packages.map(
                (package) => TicketchainCard(
                  title: package.name,
                  subtitle: '${package.price}€',
                  leading: const Icon(Icons.qr_code_rounded),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
