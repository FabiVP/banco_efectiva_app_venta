class VisitaPlanificada {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String clienteDni;
  final String direccion;
  final double latitud;
  final double longitud;
  final String motivo; // 'Renovación', 'Cobranza', 'Prospección', 'Seguimiento'
  final int orden;
  final bool completada;
  final DateTime? horaInicio;
  final DateTime? horaFin;
  final String? observaciones;
  final DateTime fechaPlanificada;

  VisitaPlanificada({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteDni,
    required this.direccion,
    this.latitud = -12.0464,
    this.longitud = -77.0428,
    required this.motivo,
    required this.orden,
    this.completada = false,
    this.horaInicio,
    this.horaFin,
    this.observaciones,
    required this.fechaPlanificada,
  });

  VisitaPlanificada copyWith({
    bool? completada,
    DateTime? horaInicio,
    DateTime? horaFin,
    String? observaciones,
  }) {
    return VisitaPlanificada(
      id: id,
      clienteId: clienteId,
      clienteNombre: clienteNombre,
      clienteDni: clienteDni,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
      motivo: motivo,
      orden: orden,
      completada: completada ?? this.completada,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      observaciones: observaciones ?? this.observaciones,
      fechaPlanificada: fechaPlanificada,
    );
  }
}
