import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nota.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PantallaVerNota extends StatefulWidget {
  final Nota nota;

  PantallaVerNota({required this.nota});

  @override
  _PantallaVerNotaState createState() => _PantallaVerNotaState();
}

class _PantallaVerNotaState extends State<PantallaVerNota> {
  late TextEditingController controladorTitulo;
  late TextEditingController controladorContenido;
  late TextEditingController controladorCompartidoCon;
  late bool fijado;
  late bool enPapelera;
  late String compartidoCon;
  Color? colorSeleccionado;


  File? imagenSeleccionada;
  Future<void> _abrirSelectorImagen() async {
    final picker = ImagePicker();
    final imagenSeleccionada = await picker.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      setState(() {
        this.imagenSeleccionada = File(imagenSeleccionada.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controladorTitulo = TextEditingController(text: widget.nota.titulo);
    controladorContenido = TextEditingController(text: widget.nota.contenido);
    fijado = widget.nota.fijado;
    enPapelera = widget.nota.enPapelera;
    compartidoCon = widget.nota.compartidoCon ?? '';
    controladorCompartidoCon = TextEditingController(text: compartidoCon);
  }

  @override
  void dispose() {
    controladorTitulo.dispose();
    controladorContenido.dispose();
    controladorCompartidoCon.dispose();
    super.dispose();
  }

  void actualizarNota(BuildContext context) async{
    final nuevoTitulo = controladorTitulo.text;
    final nuevoContenido = controladorContenido.text;

    String imagenUrl = '';
    if (imagenSeleccionada != null) {
      final storageRef = FirebaseStorage.instance.ref().child('imagenes').child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(imagenSeleccionada!);
      final snapshot = await uploadTask.whenComplete(() => null);
      if (snapshot.state == TaskState.success) {
        imagenUrl = await storageRef.getDownloadURL();
      }
    }

    FirebaseFirestore.instance.collection('notas').doc(widget.nota.id).update({
      'titulo': nuevoTitulo,
      'contenido': nuevoContenido,
      'fijado': fijado,
      'enPapelera': enPapelera,
      'compartidoCon': compartidoCon,
      'imagenUrl': imagenUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nota actualizada')),
    );
  }

  void enviarAPapelera() {
    setState(() {
      enPapelera = true;
      fijado = false;
      actualizarNota(context); // Actualizar la nota en Firestore
    });
  }

  void fijarNota() {
    setState(() {
      fijado = true;
      enPapelera = false;
      actualizarNota(context); // Actualizar la nota en Firestore
    });
  }

  void desfijarNota() {
    setState(() {
      fijado = false;
      actualizarNota(context); // Actualizar la nota en Firestore
    });
  }

  void establecerCompartidoCon() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Compartir con otro usuario'),
          content: TextField(
            controller: controladorCompartidoCon,
            decoration: InputDecoration(
              labelText: 'Correo del usuario',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Compartir'),
              onPressed: () {
                setState(() {
                  compartidoCon = controladorCompartidoCon.text;
                  actualizarNota(context); // Actualizar la nota en Firestore
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Color(int.parse("0x${widget.nota.color ?? "ffffffff"}"))
    ,
      appBar: AppBar(
        title: Text('Nota'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'papelera') {
                enviarAPapelera();
              } else if (value == 'fijar') {
                fijarNota();
              } else if (value == 'desfijar') {
                desfijarNota();
              } else if (value == 'compartir') {
                establecerCompartidoCon();
              }
              else if (value == 'color') {
                seleccionarColor();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'papelera',
                child: Text('Enviar a papelera'),
              ),
              if (fijado)
                PopupMenuItem(
                  value: 'desfijar',
                  child: Text('Desfijar'),
                )
              else
                PopupMenuItem(
                  value: 'fijar',
                  child: Text('Fijar'),
                ),
              PopupMenuItem(
                value: 'compartir',
                child: Text('Compartir con otro usuario'),
              ),
              PopupMenuItem(
                value: 'color',
                child: Text('Seleccionar color'),
              ),
            ],
          ),
        ],
      ),
      body:
      Padding(

        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: null,
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: _abrirSelectorImagen,
              child: Text('Seleccionar imagen'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => actualizarNota(context),
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
  void seleccionarColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: colorSeleccionado ?? Colors.white,
              onColorChanged: (Color color) {
                setState(() {
                  colorSeleccionado = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                guardarColor();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void guardarColor() {
    final colorHex = colorSeleccionado != null ? colorSeleccionado!.value.toRadixString(16) : null;
    FirebaseFirestore.instance.collection('notas').doc(widget.nota.id).update({
      'color': colorHex,
    });
  }

}
