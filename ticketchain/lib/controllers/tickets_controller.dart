import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';

class TicketsController extends GetxController {
  final recipientController = TextEditingController();

  RxList<Ticket> ticketsSelected = <Ticket>[].obs;

  Future<bool> giftTickets() async {
    return await EventService.to.giftTickets(
      ticketsSelected.first.event.address,
      recipientController.text,
      ticketsSelected,
    );
  }

  Future<bool> refundTickets() async {
    return await EventService.to.refundTickets(
      ticketsSelected.first.event.address,
      ticketsSelected,
    );
  }
}
