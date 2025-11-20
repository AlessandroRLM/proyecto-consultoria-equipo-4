abstract class ForPersistingRequest {
  /// Retorna `true` si ya se ha persistido una solicitud de credencial.
  Future<bool> hasRequestBeenPersisted();

  /// Persiste una solicitud de credencial.
  Future<void> persistRequest();
}