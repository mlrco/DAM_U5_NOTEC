import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nota.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaAgregarNota extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  final CollectionReference coleccionNotas =
  FirebaseFirestore.instance.collection('notas');

  final TextEditingController controladorTitulo = TextEditingController();
  final TextEditingController controladorContenido = TextEditingController();

  void agregarNota(BuildContext context) {
    final titulo = controladorTitulo.text;
    final contenido = controladorContenido.text;

    DocumentReference documentReferencia = coleccionNotas.doc();
    String id = documentReferencia.id;

    Nota nuevaNota = Nota(
      id: id,
      titulo: titulo,
      contenido: contenido,
      propietario: user.email ?? "",
      fijado: false,
      enPapelera: false,
      color: "ffffffff",
    );

    documentReferencia.set(nuevaNota.toMap());
    print(nuevaNota.id ?? "");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar nota'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controladorTitulo,
              decoration: InputDecoration(
                labelText: 'Título',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controladorContenido,
              decoration: InputDecoration(
                labelText: 'Contenido',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => agregarNota(context),
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
