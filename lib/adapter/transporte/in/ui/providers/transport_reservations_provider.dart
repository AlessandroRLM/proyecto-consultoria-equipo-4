import 'package:flutter/material.dart';

class TransportReservationsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reservations = [];

  List<Map<String, dynamic>> get reservations => _reservations;

  // placeholder para obtener datos desde el backend
  Future<void> fetchReservations() async {
    // Implementar llamada al backend aquí
    // Por ahora solo notifica a los listeners (los datos ya están cargados)
    notifyListeners();
  }

  // Método para actualizar las reservas (por ejemplo después de respuesta del backend)
  void updateReservations(List<Map<String, dynamic>> newReservations) {
    _reservations = newReservations;
    notifyListeners();
  }

  // Método para agregar una nueva reserva
  void addReservation(Map<String, dynamic> reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  // Método para eliminar una reserva
  void removeReservation(int index) {
    if (index >= 0 && index < _reservations.length) {
      _reservations.removeAt(index);
      notifyListeners();
    }
  }
}
