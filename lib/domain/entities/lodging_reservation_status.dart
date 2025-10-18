enum LodgingReservationStatus {
  pendiente('Pendiente'),
  cursada('Cursada'),
  activa('Activa'),
  aceptada('Aceptada'),
  iniciada('Iniciada'),
  finalizada('Finalizada');

  const LodgingReservationStatus(this.displayName);
  final String displayName;
}
