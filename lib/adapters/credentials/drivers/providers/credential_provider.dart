import 'package:flutter/material.dart';
import 'package:mobile/ports/credentials/driven/for_persisting_request.dart';

class CredentialProvider extends ChangeNotifier {
  final ForPersistingRequest _persistingRequestRepository;
  
  bool _isPersisted = false;
  bool _isLoading = false;
  String? _error;

  bool get isPersisted => _isPersisted;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CredentialProvider(this._persistingRequestRepository) {
    loadPersistationValue();
  }

  Future<void> loadPersistationValue() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isPersisted = await _persistingRequestRepository.hasRequestBeenPersisted();
      _error = null;
    } catch (e) {
      _error = 'Ocurrió un error al cargar la solicitud.';
      _isPersisted = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadPersistationValue();
  }
  
  // Método para actualizar el estado después de crear una solicitud
  void markAsPersisted() {
    _isPersisted = true;
    notifyListeners();
  }
}