import 'package:flutter/material.dart';

class LodgingReservation {
  final String name;
  final String address;
  final DateTime startDate;
  final DateTime endDate;

  LodgingReservation({
    required this.name,
    required this.address,
    required this.startDate,
    required this.endDate,
  });
}

class LodgingProvider with ChangeNotifier {
  final List<LodgingReservation> _reservations = [];

  List<LodgingReservation> get reservations => _reservations;

  void addReservation(LodgingReservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }
}
