class Cliente {
  final String id;
  final String dni;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String telefono;
  final String direccion;
  final String email;
  final DateTime fechaNacimiento;
  final String estadoCivil;
  final String ocupacion;
  final double ingresoMensual;
  final double latitud;
  final double longitud;
  // Historial crediticio
  final int creditosAnteriores;
  final double montoMaximoAprobado;
  final bool tieneRenovacion;
  final DateTime? fechaUltimoCredito;
  final String calificacion; // A, B, C, D
  final List<ProductoActivo> productosActivos;
  final String? fotoUrl;

  Cliente({
    required this.id,
    required this.dni,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.telefono,
    required this.direccion,
    this.email = '',
    required this.fechaNacimiento,
    this.estadoCivil = 'Soltero(a)',
    this.ocupacion = '',
    this.ingresoMensual = 0,
    this.latitud = 0,
    this.longitud = 0,
    this.creditosAnteriores = 0,
    this.montoMaximoAprobado = 0,
    this.tieneRenovacion = false,
    this.fechaUltimoCredito,
    this.calificacion = 'N',
    this.productosActivos = const [],
    this.fotoUrl,
  });

  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';

  String get iniciales {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dni': dni,
      'nombres': nombres,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'telefono': telefono,
      'direccion': direccion,
      'email': email,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'estadoCivil': estadoCivil,
      'ocupacion': ocupacion,
      'ingresoMensual': ingresoMensual,
      'latitud': latitud,
      'longitud': longitud,
      'creditosAnteriores': creditosAnteriores,
      'montoMaximoAprobado': montoMaximoAprobado,
      'tieneRenovacion': tieneRenovacion ? 1 : 0,
      'fechaUltimoCredito': fechaUltimoCredito?.toIso8601String(),
      'calificacion': calificacion,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] ?? '',
      dni: map['dni'] ?? '',
      nombres: map['nombres'] ?? '',
      apellidoPaterno: map['apellidoPaterno'] ?? '',
      apellidoMaterno: map['apellidoMaterno'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      email: map['email'] ?? '',
      fechaNacimiento: DateTime.tryParse(map['fechaNacimiento'] ?? '') ??
          DateTime(2000, 1, 1),
      estadoCivil: map['estadoCivil'] ?? 'Soltero(a)',
      ocupacion: map['ocupacion'] ?? '',
      ingresoMensual: (map['ingresoMensual'] ?? 0).toDouble(),
      latitud: (map['latitud'] ?? 0).toDouble(),
      longitud: (map['longitud'] ?? 0).toDouble(),
      creditosAnteriores: map['creditosAnteriores'] ?? 0,
      montoMaximoAprobado: (map['montoMaximoAprobado'] ?? 0).toDouble(),
      tieneRenovacion: map['tieneRenovacion'] == 1,
      fechaUltimoCredito: map['fechaUltimoCredito'] != null
          ? DateTime.tryParse(map['fechaUltimoCredito'])
          : null,
      calificacion: map['calificacion'] ?? 'N',
    );
  }
}

class ProductoActivo {
  final String tipo; // 'Crédito Personal', 'Crédito Grupal', etc.
  final double montoOriginal;
  final double saldoPendiente;
  final int cuotasPagadas;
  final int cuotasTotales;
  final DateTime fechaDesembolso;
  final String estado;

  ProductoActivo({
    required this.tipo,
    required this.montoOriginal,
    required this.saldoPendiente,
    required this.cuotasPagadas,
    required this.cuotasTotales,
    required this.fechaDesembolso,
    this.estado = 'Vigente',
  });

  double get porcentajeAvance =>
      cuotasTotales > 0 ? cuotasPagadas / cuotasTotales : 0;
}
