class Tarea {
   int idtarea;
   String idmateria;
   String f_entrega;
   String descripcion;

  Tarea({
    required this.idmateria,
    required this.f_entrega,
    required this.descripcion,
    required this.idtarea ,
  });

  Map<String,dynamic> toJSON(){
    return {
      'idtarea' : idtarea,
      'idmateria': idmateria,
      'f_entrega': f_entrega,
      'descripcion': descripcion
    };
  }
}
