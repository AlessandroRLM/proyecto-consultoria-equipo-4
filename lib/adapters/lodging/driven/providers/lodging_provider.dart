import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LodgingProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reservations = [];

  List<Map<String, dynamic>> get reservations => _reservations;

  Future<void> fetchReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('lodging_reservations');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _reservations = jsonList.map((json) => Map<String, dynamic>.from(json)).toList();
    }
    notifyListeners();
  }

  Future<void> saveReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_reservations.map((r) => Map<String, dynamic>.from(r)).toList());
    await prefs.setString('lodging_reservations', jsonString);
  }

  void addReservation(Map<String, dynamic> reservation) {
    _reservations.add(reservation);
    saveReservations();
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

  DateTime getMinReservableDate() {
    const int cutoffWeekday = 3; 
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysToNextMonday = (DateTime.monday - todayWeekday + 7) % 7;
    final nextMonday = now.add(Duration(days: daysToNextMonday == 0 ? 7 : daysToNextMonday));
    DateTime minReservableDate;
    if (todayWeekday < cutoffWeekday) {
      minReservableDate = nextMonday;
    } else {
      minReservableDate = nextMonday.add(const Duration(days: 7));
    }
    return minReservableDate;
  }
}
