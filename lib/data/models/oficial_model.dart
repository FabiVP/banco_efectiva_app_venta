class Oficial {
  final String id;
  final String codigo;
  final String nombreCompleto;
  final String email;
  final String zona;
  final String agencia;
  final String fotoUrl;
  final double metaDiaria;
  final double metaMensual;

  Oficial({
    required this.id,
    required this.codigo,
    required this.nombreCompleto,
    required this.email,
    required this.zona,
    required this.agencia,
    this.fotoUrl = '',
    this.metaDiaria = 0,
    this.metaMensual = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'zona': zona,
      'agencia': agencia,
      'fotoUrl': fotoUrl,
      'metaDiaria': metaDiaria,
      'metaMensual': metaMensual,
    };
  }

  factory Oficial.fromMap(Map<String, dynamic> map) {
    return Oficial(
      id: map['id'] ?? '',
      codigo: map['codigo'] ?? '',
      nombreCompleto: map['nombreCompleto'] ?? '',
      email: map['email'] ?? '',
      zona: map['zona'] ?? '',
      agencia: map['agencia'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
      metaDiaria: (map['metaDiaria'] ?? 0).toDouble(),
      metaMensual: (map['metaMensual'] ?? 0).toDouble(),
    );
  }
}
