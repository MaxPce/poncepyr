import 'package:app_admin/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/utils/state_managment.dart';

class EditItem extends StatelessWidget {
  final String uid;
  final String currentDescripcion;
  final String currentEstado;
  final String tipoSolicitud;

  const EditItem({
    Key? key,
    required this.uid,
    required this.currentDescripcion,
    required this.currentEstado,
    required this.tipoSolicitud,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController respuestaController = TextEditingController();
    final TextEditingController estadoController = TextEditingController(text: currentEstado);
    final List<String> estados = ['Activa', 'En espera', 'Inactiva'];

    if (!estados.contains(currentEstado)) {
      estados.add(currentEstado);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder Solicitud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: estadoController.text,
              onChanged: (String? value) {
                estadoController.text = value ?? '';
              },
              items: estados
                  .map((String e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: respuestaController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Respuesta',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _responderSolicitud(
                uid,
                estadoController.text,
                respuestaController.text,
                context,
              ),
              child: const Text("Responder"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _responderSolicitud(
    String uid,
    String estado,
    String respuesta,
    BuildContext context,
  ) async {
    try {
      // Actualizar la solicitud en la base de datos
      await FirebaseFirestore.instance.collection(tipoSolicitud).doc(uid).update({
        'estado': estado,
        'respuesta': respuesta,
      });
      Navigator.pop(context, true); // Indicate that the item was updated
    } catch (error) {
      print('Error al actualizar en Firestore: $error');
      // Aquí puedes agregar lógica para manejar el error, como mostrar un diálogo de error
    }
  }
}
