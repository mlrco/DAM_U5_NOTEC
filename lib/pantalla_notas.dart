import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nota.dart';
import 'pantalla_ver_nota.dart';
import 'pantalla_agregar_nota.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaNotas extends StatefulWidget {
  @override
  _PantallaNotasState createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }


  final CollectionReference coleccionNotas =
  FirebaseFirestore.instance.collection('notas');
  bool mostrarPapelera = false;
  bool mostrarCompartidas = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas. Usuario: ${user.email}'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Notas'),
              onTap: () {
                setState(() {
                  mostrarPapelera = false;
                  mostrarCompartidas = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Papelera'),
              onTap: () {
                setState(() {
                  mostrarPapelera = true;
                  mostrarCompartidas = false;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: Text('Compartidas Conmigo'),
              onTap: () {
                setState(() {
                  mostrarPapelera = false;
                  mostrarCompartidas = true;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: () {
                setState(() {
                  signUserOut();
                });
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mostrarPapelera) {
            _mostrarDialogoConfirmacion();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PantallaAgregarNota()),
            );
          }
        },
        child: Icon(mostrarPapelera ? Icons.delete : Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: mostrarCompartidas
            ? coleccionNotas.where('compartidoCon', isEqualTo: user.email).snapshots()
            : coleccionNotas.where('propietario', isEqualTo: user.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error al obtener las notas');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final notas = snapshot.data!.docs;

          final List<Nota> notasFijadas = [];
          final List<Nota> notasNormales = [];

          for (var nota in notas) {
            final notaData = nota.data() as Map<String, dynamic>;
            final nuevaNota = Nota(
              id: notaData['id'],
              titulo: notaData['titulo'] as String? ?? '',
              contenido: notaData['contenido'] as String? ?? '',
              propietario: notaData['propietario'] as String? ?? '',
              fijado: notaData['fijado'] as bool? ?? false,
              enPapelera: notaData['enPapelera'] as bool? ?? false,
              imagenUrl: notaData['imagenUrl'] as String?,
              color: notaData['color'] as String?,

            );

            if (mostrarPapelera && !nuevaNota.enPapelera) {
              continue;
            }

            if (!mostrarPapelera && nuevaNota.enPapelera) {
              continue;
            }


            if (nuevaNota.fijado) {
              notasFijadas.add(nuevaNota);
            } else {
              notasNormales.add(nuevaNota);
            }
          }

          final List<Nota> todasLasNotas =
          [...notasFijadas, ...notasNormales];

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: todasLasNotas.length,
            itemBuilder: (context, index) {
              final nota = todasLasNotas[index];

              return GestureDetector(
                onTap: () {
                  //
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaVerNota(nota: nota),
                    ),
                  );
                },
                child: Card(
                  color: Color(int.parse("0x${nota.color??"ffffffff"}")),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(nota.titulo),
                      SizedBox(height: 8),
                      ClipRect(
                        child: Text(
                          nota.contenido,
                          maxLines: 3, // Establecer el número máximo de líneas visibles
                          overflow: TextOverflow.ellipsis, // Mostrar "..." al final si hay desbordamiento
                        ),
                      ),
                      if (nota.imagenUrl != null && nota.imagenUrl!="")
                        SizedBox(
                          height: 100,
                          child: Image.network(nota.imagenUrl!),
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _eliminarNotasEnPapelera() {
    coleccionNotas.where('enPapelera', isEqualTo: true).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar todas las notas en la papelera'),
          content: Text('¿Estás seguro de que deseas eliminar todas las notas en la papelera?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                _eliminarNotasEnPapelera();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
