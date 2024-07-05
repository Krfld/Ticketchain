import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/utils.dart';

class EventDetails extends StatelessWidget {
  const EventDetails({
    super.key,
    required this.event,
    required this.children,
  });

  final EventModel event;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Text(
            event.eventConfig.name,
            style: TicketchainTextStyle.name,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton.icon(
                  label: Text(event.eventConfig.location),
                  icon: const Icon(Icons.place_rounded),
                  onPressed: () =>
                      MapsLauncher.launchQuery(event.eventConfig.location),
                ),
              ),
              Text(
                'Date ${formatDate(event.eventConfig.date)}',
                style: TicketchainTextStyle.text,
              ),
            ],
          ),
          Text(
            event.isRefundable
                ? 'Refund ${event.eventConfig.refundPercentage * 100}% until ${formatDate(event.eventConfig.noRefundDate)}'
                : 'No refund available',
            style: TicketchainTextStyle.text,
          ),
          Text(
            event.eventConfig.description,
            style: TicketchainTextStyle.text,
          ),
          const Divider(),
          Wrap(
            runSpacing: 20,
            children: children,
          ),
        ],
      ),
    );
  }
}
