class Cliente {
  final String id;
  final String? codCliente;
  final String numeroDocumento;
  final String tipoDocumento;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String? estadoCivil;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? tipoNegocio;
  final String? nombreNegocio;
  final int? antiguedadNegocioMeses;
  final double? ingresosEstimados;
  final double? lat;
  final double? lng;
  final String? calificacionSbs;
  final bool esProspecto;

  Cliente({
    required this.id,
    this.codCliente,
    required this.numeroDocumento,
    this.tipoDocumento = 'DNI',
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.estadoCivil,
    this.telefono,
    this.email,
    this.direccion,
    this.tipoNegocio,
    this.nombreNegocio,
    this.antiguedadNegocioMeses,
    this.ingresosEstimados,
    this.lat,
    this.lng,
    this.calificacionSbs,
    this.esProspecto = false,
  });

  String get nombreCompleto => '$nombres $apellidos';

  String get iniciales {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String get dniCensurado {
    if (numeroDocumento.length >= 5) {
      return '***${numeroDocumento.substring(numeroDocumento.length - 3)}';
    }
    return '***';
  }

  Map<String, dynamic> toMap() => {
    if (codCliente != null) 'cod_cliente': codCliente,
    'numero_documento': numeroDocumento,
    'tipo_documento': tipoDocumento,
    'nombres': nombres,
    'apellidos': apellidos,
    if (fechaNacimiento != null) 'fecha_nacimiento': fechaNacimiento!.toIso8601String().split('T').first,
    if (estadoCivil != null) 'estado_civil': estadoCivil,
    if (telefono != null) 'telefono': telefono,
    if (email != null) 'email': email,
    if (direccion != null) 'direccion': direccion,
    if (tipoNegocio != null) 'tipo_negocio': tipoNegocio,
    if (nombreNegocio != null) 'nombre_negocio': nombreNegocio,
    if (antiguedadNegocioMeses != null) 'antiguedad_negocio_meses': antiguedadNegocioMeses,
    if (ingresosEstimados != null) 'ingresos_estimados': ingresosEstimados,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    if (calificacionSbs != null) 'calificacion_sbs': calificacionSbs,
    'es_prospecto': esProspecto,
  };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'] ?? '',
    codCliente: json['cod_cliente']?.toString(),
    numeroDocumento: json['numero_documento'] ?? '',
    tipoDocumento: json['tipo_documento'] ?? 'DNI',
    nombres: json['nombres'] ?? '',
    apellidos: json['apellidos'] ?? '',
    fechaNacimiento: json['fecha_nacimiento'] != null
        ? DateTime.tryParse(json['fecha_nacimiento'])
        : null,
    estadoCivil: json['estado_civil']?.toString(),
    telefono: json['telefono']?.toString(),
    email: json['email']?.toString(),
    direccion: json['direccion']?.toString(),
    tipoNegocio: json['tipo_negocio']?.toString(),
    nombreNegocio: json['nombre_negocio']?.toString(),
    antiguedadNegocioMeses: json['antiguedad_negocio_meses'] as int?,
    ingresosEstimados: (json['ingresos_estimados'] as num?)?.toDouble(),
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    calificacionSbs: json['calificacion_sbs']?.toString(),
    esProspecto: json['es_prospecto'] as bool? ?? false,
  );
}

class ProductoActivo {
  final String tipo;
  final double montoDesembolsado;
  final double saldoCapital;
  final int cuotasPagadas;
  final int cuotasTotales;
  final DateTime? fechaDesembolso;
  final String estado;
  final int diasMora;

  ProductoActivo({
    required this.tipo,
    required this.montoDesembolsado,
    required this.saldoCapital,
    required this.cuotasPagadas,
    required this.cuotasTotales,
    this.fechaDesembolso,
    this.estado = 'vigente',
    this.diasMora = 0,
  });

  double get porcentajeAvance =>
      cuotasTotales > 0 ? cuotasPagadas / cuotasTotales : 0;
}
