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
  final List<LodgingReservation> _reservations = [];

  List<LodgingReservation> get reservations => _reservations;

  void addReservation(LodgingReservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  final List<Map<String, String>> clinics = [
    {
      "name": "Centro Médico Andes Salud Talca",
      "city": "Talca",
      "address": "Cuatro Nte. 1656, 3467384 Talca, Maule",
    },
    {
      "name": "Clínica Santa María",
      "city": "Talca",
      "address": "Calle Falsa 123, Talca, Maule",
    },
  ];
  
  Map<String, String>? getClinicInfoByName(String area) {
    try {
      return clinics.firstWhere((clinic) => clinic["name"] == area);
    } catch (e) {
      return null;
    }
  }
}
