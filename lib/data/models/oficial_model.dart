class Oficial {
  final String id;
  final String codigoEmpleado;
  final String nombres;
  final String apellidos;
  final String? agenciaId;
  final String? agenciaNombre;
  final String perfil;
  final String? tokenFcm;
  final String? codAsesor;

  Oficial({
    required this.id,
    required this.codigoEmpleado,
    required this.nombres,
    required this.apellidos,
    this.agenciaId,
    this.agenciaNombre,
    this.perfil = 'operador',
    this.tokenFcm,
    this.codAsesor,
  });

  String get nombreCompleto => '$nombres $apellidos';

  Map<String, dynamic> toMap() => {
    'id': id,
    'codigo_empleado': codigoEmpleado,
    'nombres': nombres,
    'apellidos': apellidos,
    'agencia_id': agenciaId,
    'agencia_nombre': agenciaNombre,
    'perfil': perfil,
    'token_fcm': tokenFcm,
    'cod_asesor': codAsesor,
  };

  factory Oficial.fromJson(Map<String, dynamic> json) => Oficial(
    id: json['id'] ?? '',
    codigoEmpleado: json['codigo_empleado'] ?? '',
    nombres: json['nombres'] ?? '',
    apellidos: json['apellidos'] ?? '',
    agenciaId: json['agencia_id']?.toString(),
    agenciaNombre: json['agencia_nombre']?.toString(),
    perfil: json['perfil'] ?? 'operador',
    tokenFcm: json['token_fcm']?.toString(),
    codAsesor: json['cod_asesor']?.toString(),
  );

  factory Oficial.fromUserMetadata(Map<String, dynamic> metadata) => Oficial(
    id: metadata['id'] ?? '',
    codigoEmpleado: metadata['codigo_empleado'] ?? '',
    nombres: metadata['nombre'] ?? '',
    apellidos: metadata['apellido'] ?? '',
    agenciaId: metadata['agencia_id']?.toString(),
    agenciaNombre: metadata['agencia_nombre']?.toString(),
    perfil: metadata['rol'] ?? 'operador',
  );
}
