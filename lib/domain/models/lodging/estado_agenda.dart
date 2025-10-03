/// Estados según EstadosAgendas.md:
/// Pendiente, Cursada, Activa, Aceptada, Iniciada, Finalizada
enum EstadoAgenda { pendiente, cursada, activa, aceptada, iniciada, finalizada }

extension EstadoAgendaX on EstadoAgenda {
  String toJson() => switch (this) {
    EstadoAgenda.pendiente => 'Pendiente',
    EstadoAgenda.cursada => 'Cursada',
    EstadoAgenda.activa => 'Activa',
    EstadoAgenda.aceptada => 'Aceptada',
    EstadoAgenda.iniciada => 'Iniciada',
    EstadoAgenda.finalizada => 'Finalizada',
  };

  static EstadoAgenda fromJson(String raw) {
    final normalized = raw.trim().toLowerCase();

    // Tolerancia a variantes/typos del dataset (e.g., "Iiciada")
    if (normalized == 'iiciada') return EstadoAgenda.iniciada;

    return switch (normalized) {
      'pendiente' => EstadoAgenda.pendiente,
      'cursada' => EstadoAgenda.cursada,
      'activa' => EstadoAgenda.activa,
      'aceptada' => EstadoAgenda.aceptada,
      'iniciada' => EstadoAgenda.iniciada,
      'finalizada' => EstadoAgenda.finalizada,
      _ => EstadoAgenda.activa, // fallback razonable
    };
  }
}
