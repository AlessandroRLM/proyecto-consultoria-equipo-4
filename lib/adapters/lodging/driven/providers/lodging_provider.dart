import 'package:flutter/material.dart';

class LodgingReservation {
  final String area;
  final String name;
  final String address;
  final String room;
  final String checkIn;
  final String checkOut;

  LodgingReservation({
    required this.area,
    required this.name,
    required this.address,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });
}

class LodgingProvider with ChangeNotifier {
  final List<LodgingReservation> _reservations = [
    LodgingReservation(
      area: "Santiago - Pudahuel",
      name: "Hostal Familiar S&G",
      address: "Diagonal Norte 8912 Pudahuel",
      room: "PRC-662",
      checkIn: "LUN 10/09",
      checkOut: "MIE 17/09",
    ),
    LodgingReservation(
      area: "Santiago - Centro",
      name: "Casa Bonita",
      address: "San Martín 120, Stgo",
      room: "STD-105",
      checkIn: "MAR 12/09",
      checkOut: "JUE 19/09",
    ),
  ];

  List<LodgingReservation> get reservations => _reservations;

  void addReservation(LodgingReservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }
}
