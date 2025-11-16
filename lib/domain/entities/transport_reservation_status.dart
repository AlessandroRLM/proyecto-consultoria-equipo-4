enum TransportReservationStatus {
  pendiente('Pendiente'),
  cursada('Cursada'),
  activa('Activa'),
  aceptada('Aceptada'),
  iniciada('Iniciada'),
  finalizada('Finalizada');

  const TransportReservationStatus(this.displayName);
  final String displayName;
}
