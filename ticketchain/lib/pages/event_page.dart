import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/pages/map_page.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/buy_tickets_modal.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class EventPage extends GetView<HomeController> {
  final EventModel event;

  const EventPage({super.key, required this.event});

  Future<void> _showBuyTicketsModal() async => await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => const BuyTicketsModal(),
      );

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
              Text(
                '${event.packages.length} packages',
                style: TicketchainTextStyle.text,
              ),
            ],
          ),
          TextButton.icon(
            label: Text(event.location.address),
            icon: const Icon(Icons.place_rounded),
            onPressed: () async => Get.to(
              () => MapsPage(
                latitude: event.location.latitude,
                longitude: event.location.longitude,
              ),
            ), // await MapsLauncher.launchQuery(event.location),
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
                  onTap: () => _showBuyTicketsModal(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
