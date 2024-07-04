import 'dart:convert';

class TicketValidationData {
  final String eventAddress;
  final List<int> tickets;
  final String ownerAddress;
  final String signature;

  TicketValidationData(
    this.eventAddress,
    this.tickets,
    this.ownerAddress,
    this.signature,
  );

  factory TicketValidationData.fromMessage(String message) {
    Map json = jsonDecode(message);
    return TicketValidationData(
      json['eventAddress'],
      List<int>.from(json['tickets']),
      json['ownerAddress'],
      json['signature'],
    );
  }

  String toMessage() => jsonEncode({
        'eventAddress': eventAddress,
        'tickets': tickets,
        'ownerAddress': ownerAddress,
        'signature': signature,
      });
}
