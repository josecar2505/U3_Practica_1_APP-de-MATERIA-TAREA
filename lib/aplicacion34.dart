import 'package:dam_u3_practica1_sqflite/materia.dart';
import 'package:dam_u3_practica1_sqflite/tarea.dart';
import 'package:flutter/material.dart';

import 'basedatos.dart';

class App34 extends StatefulWidget {
  const App34({super.key});

  @override
  State<App34> createState() => _App34State();
}

class _App34State extends State<App34> {
  int _index = 0, idtareaaux = 0, contador=0;
  String? selectedMateria;
  List<Tarea> data = [];
  List<Materia> materias = [];
  List<String> semestres  = ["ENE-JUN2020","AGO-DIC2020","ENE-JUN2021","AGO-DIC2021","ENE-JUN2022","AGO-DIC2022","ENE-JUN2023","AGO-DIC2023"];
  String idm = "";
  String fechaActual  = DateTime.now().toString().split(" ")[0];

  final idmateria = TextEditingController();
  final f_entrega = TextEditingController();
  final descripcion = TextEditingController();
  final idmateriaM = TextEditingController();
  final nombre = TextEditingController();
  final semestre = TextEditingController();
  final docente = TextEditingController();

  void actualizarListas() async {
    List<Tarea> temp = await DB.mostrarTarea();
    List<Materia> temp2 = await DB.mostrarMateria();
    setState(() {
      data = temp;
      contador =0;
      if(data.isNotEmpty) { //Contabilizar las tareas existentes
        for (int i = 0; i < data.length; i++) {
          if (data[i].f_entrega == fechaActual) {
            contador++;
          }
        }
      }

      materias = temp2;
    });
  }

  @override
  void initState() {
    actualizarListas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("APP TAREAS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,),),
        centerTitle: true,
        backgroundColor: Colors.blue,
        shadowColor: Colors.grey,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4C60AF),
                Color.fromARGB(255, 37, 195, 248),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: dinamico(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pendientes hoy: $contador"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Agregar tarea"),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Materia"),
        ],
        currentIndex: _index,
        onTap: (indice) {
          setState(() {
            _index = indice;
          });
        },
      ),
    );
  }

  Widget dinamico() {
    switch (_index) {
      case 1:
        return capturarTarea();
      case 2:
        return mostrarListaMaterias();
    }
    return mostrarListaTareas();
  }

  Widget mostrarListaTareas() {
    final List<Tarea> tareasHoy = [];
    final List<Tarea> tareasFuturas = [];

    // Separar las tareas en las dos listas
    for (final tarea in data) {
      if (tarea.f_entrega == fechaActual) {
        tareasHoy.add(tarea);
      } else {
        tareasFuturas.add(tarea);
      }
    }

    // Ordenar la lista de tareas futuras por fecha de entrega
    tareasFuturas.sort((a, b) => a.f_entrega.compareTo(b.f_entrega));

    // Combinar ambas listas
    final tareasOrdenadas = [...tareasHoy, ...tareasFuturas];

    return ListView.builder(
      itemCount: tareasOrdenadas.length,
      itemBuilder: (context, indice) {
        final tarea = tareasOrdenadas[indice];
        final esTareaHoy = tarea.f_entrega == fechaActual;
        final colorTarea = esTareaHoy ? Colors.cyan[200] : Colors.grey[200];

        String nombreMatAux ="";
        for(int i=0; i<materias.length; i++){
          if(materias[i].idmateria == tarea.idmateria){
            nombreMatAux = materias[i].nombre;
            break;
          }
        }

        return Card(
          color: colorTarea,
          child: ListTile(
            title: Text("${tarea.descripcion}"),
            subtitle: Text("${nombreMatAux}\n${tarea.f_entrega}"),
            leading: CircleAvatar(
              child: Text("${tarea.idmateria}"),
              radius: 25,
              backgroundColor: Colors.white,
            ),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertMensaje("Confirmar eliminación", "¿Seguro que deseas eliminar este elemento?", 0, indice);
                  },
                );
              },
              icon: Icon(Icons.delete),
            ),
            isThreeLine: true,
            onTap: () {
              setState(() {
                actualizarTarea(tarea, indice);
              });
            },
          ),
        );
      },
    );
  }

  Widget capturarTarea() {
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        ComboMateria(),
        SizedBox(height: 20,),
        TextField(
          controller: f_entrega,
          decoration: InputDecoration(
              filled: true,
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              labelText: "Fecha de entrega:"),
          readOnly: true,
            onTap: (){
              _selectDate(f_entrega);
            },
        ),
        SizedBox(height: 25,),
        TextField(
          controller: descripcion,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              labelText: "Descripción:"),
        ),
        SizedBox(height: 25,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () {
                  var temporal = Tarea(
                      idtarea: idtareaaux+1,
                      idmateria: idm,
                      f_entrega: f_entrega.text,
                      descripcion: descripcion.text);
                  DB.insertarTarea(temporal).then((value) {
                    setState(() {
                      idtareaaux += 1;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE INSERTÓ CON ÉXITO")));
                    });
                    idmateria.text = "";
                    f_entrega.text = "";
                    descripcion.text = "";
                    actualizarListas();
                  });
                },
                child: Text("Insertar")),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _index = 0;
                  });
                },
                child: Text("Cancelar")),
          ],
        )
      ],
    );
  }

  void actualizarTarea(Tarea t, int ind) {
    selectedMateria = t.idmateria;
    f_entrega.text = t.f_entrega;
    descripcion.text = t.descripcion;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return (Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 30,
                right: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("TAREA",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(height: 20,),
                ComboMateria(),
                SizedBox(height: 15,),
                TextField(
                  controller: f_entrega,
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      labelText: "Fecha de entrega:"),
                  readOnly: true,
                  onTap: (){
                    _selectDate(f_entrega);
                  },
                ),
                SizedBox(height: 15,),
                TextField(
                  controller: descripcion,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      labelText: "Descripción:"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          //Validación
                          idmateria.text = idm;
                          t.idmateria = idmateria.text;
                          t.f_entrega = f_entrega.text;
                          t.descripcion = descripcion.text;
                          DB.actualizarTarea(t).then((value) {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE ACTUALIZÓ EL REGISTRO CON ÉXITO")));
                            });
                            idmateria.text = "";
                            f_entrega.text = "";
                            descripcion.text = "";
                            actualizarListas();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Guardar")),
                    ElevatedButton(
                        onPressed: () {
                          idmateria.text = "";
                          f_entrega.text = "";
                          descripcion.text = "";
                          Navigator.pop(context);
                        },
                        child: const Text("Cancelar")),
                  ],
                ),
              ],
            ),
          ));
        });
  }

  //---------- WIDGETS MATERIAS ------------------------------------------------
  Widget mostrarListaMaterias() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            idmateriaM.text = "";
            nombre.text = "";
            semestre.text = "";
            docente.text = "";
            capturarMateria();
          });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView.builder(
        itemCount: materias.length,
        itemBuilder: (context, indice) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Text("${materias[indice].nombre}"),
                  subtitle: Text("${materias[indice].docente}\n${materias[indice].semestre}"),
                  leading: CircleAvatar(
                    child: Text("${materias[indice].idmateria}"),
                    radius: 25,
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertMensaje("Confirmar eliminación", "¿Seguro que desea eliminar la materia ${materias[indice].nombre}?", 1, indice);
                        },
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    setState(() {
                      actualizarMateria(materias[indice], indice);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void actualizarMateria(Materia m, int ind) {
    nombre.text = m.nombre;
    semestre.text = m.semestre;
    docente.text = m.docente;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return (Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 30,
                right: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("MATERIA",style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Nombre:"),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: semestre,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Semestre:"),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: docente,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Docente:"),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          //Validación
                          m.nombre = nombre.text;
                          m.semestre = semestre.text;
                          m.docente = docente.text;
                          DB.actualizarMateria(m).then((value) {
                            if(value>0){
                              setState(() {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE ACTUALIZÓ EL REGISTRO ${m.idmateria}")));
                              });
                              nombre.text = "";
                              semestre.text = "";
                              docente.text = "";
                              actualizarListas();
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Guardar")),
                    ElevatedButton(
                        onPressed: () {
                          nombre.text = "";
                          semestre.text = "";
                          docente.text = "";
                          Navigator.pop(context);
                        },
                        child: const Text("Cancelar")),
                  ],
                ),
              ],
            ),
          ));
        });
  }

  void capturarMateria() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return (Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 30,
                  right: 30,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("NUEVA MATERIA",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  SizedBox(height: 25,),
                  TextField(
                    controller: idmateriaM,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),labelText: "ID:"),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: nombre,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Nombre:"),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: semestre,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Semestre:"),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: docente,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))), labelText: "Docente:"),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            var temporal = Materia(
                                idmateria: idmateriaM.text,
                                nombre: nombre.text,
                                semestre: semestre.text,
                                docente: docente.text);

                            bool yaExiste = false;
                            for(int i=0; i<materias.length; i++){
                              if(materias[i].idmateria == temporal.idmateria){
                                yaExiste = true;
                                break;
                              }
                            }

                            if(!yaExiste) {
                              DB.insertarMateria(temporal).then((value) {
                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE INSERTÓ CON ÉXITO")));
                                });
                                idmateriaM.text = "";
                                nombre.text = "";
                                semestre.text = "";
                                docente.text = "";
                                actualizarListas();
                              });
                            }else{
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("ALERTA"),
                                    content:
                                    Text("¡LA MATERIA QUE TRATA DE INGRESA YA EXISTE!"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Ok"),
                                      ),
                                    ],
                                  );
                                },
                              );
                              Navigator.of(context).pop();
                              idmateriaM.text = "";
                              nombre.text = "";
                              semestre.text = "";
                              docente.text = "";
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text("Insertar")),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _index = 0;
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancelar")),
                    ],
                  ),
                ],
              )));
        });
  }

  //----------------------------------------------------------------------------
  Container ComboMateria(){
    return Container(
      child: InputDecorator(
        decoration: customDecoration,
        child: DropdownButton<String>(
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 32,
          isExpanded: true,
          value: selectedMateria,
          items: materias.map((materia) {
            return DropdownMenuItem<String>(
              value: materia.idmateria,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(materia.nombre),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMateria = value;
              idm = selectedMateria.toString();
            });
          },
          underline: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.transparent)),)),
        ),
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controlador) async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100)
    );

    if(_picked != null){
      setState(() {
        controlador.text = _picked.toString().split(" ")[0];
      });
    }
  }

  InputDecoration customDecoration = InputDecoration(
    prefixIcon: Icon(Icons.book_outlined),
    labelText: "Selecciona una materia",
    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey),
    ),
  );

  AlertDialog AlertMensaje(String titulo, String contenido, int accion, int indice, ){
    return AlertDialog(
      title: Text(titulo),
      content:
      Text(contenido),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            if(accion == 0) {
              DB.eliminar(data[indice].idtarea).then((value) {
                  setState(() {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE ELIMINÓ LA TAREA CORRECTAMENTE")));
                  });
                actualizarListas();
              });
            }
            if(accion == 1){
              DB.eliminarMateria(materias[indice].idmateria).then((value) {
                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE ELIMINÓ LA MATERIA CORRECTAMENTE")));
                });
                actualizarListas();
              });
            }
            Navigator.of(context).pop();
          },
          child: Text("Eliminar"),
        ),
      ],
    );
  }
}
