class Denuncia {
  final int id;
  final int usuario;
  final String titulo;
  final String descripcion;
  final String tipo;
  final double latitud;
  final double longitud;
  final String fecha;
  final String estado;

  Denuncia({
    required this.id,
    required this.usuario,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.latitud,
    required this.longitud,
    required this.fecha,
    required this.estado,
  });

  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id']          is int     ? json['id']          as int    : 0,
      usuario: json['usuario'] is int     ? json['usuario']     as int    : 0,
      titulo: (json['titulo']   as String?)    ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      tipo: (json['tipo']      as String?)    ?? '',
      latitud: (json['latitud']   as num?)  != null
          ? (json['latitud'] as num).toDouble()
          : 0.0,
      longitud: (json['longitud']  as num?)  != null
          ? (json['longitud'] as num).toDouble()
          : 0.0,
      fecha: (json['fecha']      as String?)  ?? '',
      estado: (json['estado']    as String?)  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'usuario': usuario,
        'titulo': titulo,
        'descripcion': descripcion,
        'tipo': tipo,
        'latitud': latitud,
        'longitud': longitud,
        'estado': estado,
      };
}
