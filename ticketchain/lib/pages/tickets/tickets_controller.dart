import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';

class TicketsController extends GetxController {
  final recipientController = TextEditingController();

  RxList<Ticket> ticketsSelected = <Ticket>[].obs;
  RxBool selecting = false.obs;

  String get eventAddress => ticketsSelected.first.event.address;

  Future<bool> giftTickets() async {
    return await EventService.to.giftTickets(
      eventAddress,
      recipientController.text,
      ticketsSelected,
    );
  }

  Future<bool> refundTickets() async {
    return await EventService.to.refundTickets(
      eventAddress,
      ticketsSelected,
    );
  }
}
