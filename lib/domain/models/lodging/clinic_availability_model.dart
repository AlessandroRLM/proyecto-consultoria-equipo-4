class ClinicAvailabilityItem {
  final String clinicName; // nombre del campo clínico
  final String residenceName; // nombre de la residencia
  final String city; // ciudad (extraída de la dirección)
  final String address; // dirección completa

  const ClinicAvailabilityItem({
    required this.clinicName,
    required this.residenceName,
    required this.city,
    required this.address,
  });
}
