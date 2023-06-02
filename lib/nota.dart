class Nota {
  String? id;
  String? compartidoCon;
  String titulo;
  String contenido;
  String propietario;
  bool fijado;
  bool enPapelera;
  String? imagenUrl;
  String? color;

  Nota({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.propietario,
    required this.fijado,
    required this.enPapelera,
    this.compartidoCon,
    this.imagenUrl,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'propietario': propietario,
      'fijado': fijado,
      'enPapelera': enPapelera,
      'imagenUrl': imagenUrl,
      'color': color,

    };
  }
  void setId(String id) {
    this.id = id;
  }

}


