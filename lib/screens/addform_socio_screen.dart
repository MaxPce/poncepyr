import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

class AddItem extends StatelessWidget {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  late Position _currentPosition;
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";

    fechaController.text = formattedDate;
    estadoController.text = 'En Espera';
    tipoController.text = 'Peticion';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          DropdownButtonFormField<String>(
            value: estadoController.text,
            onChanged: (String? value) {
              estadoController.text = value ?? '';
            },
            items: ['En Espera']
                .map((String e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            decoration: const InputDecoration(labelText: 'Estado'),
          ),
          TextField(
            controller: fechaController,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Fecha'),
          ),
          DropdownButtonFormField<String>(
            value: tipoController.text,
            onChanged: (String? value) {
              tipoController.text = value ?? '';
            },
            items: ['Peticion', 'Queja', 'Reclamo', 'Vivencia']
                .map((String e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            decoration: const InputDecoration(labelText: 'Tipo'),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles();

              if (result != null) {
                _selectedFile = File(result.files.single.path!);
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'Seleccionar archivo',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              final descripcion = descripcionController.text;
              final estado = estadoController.text;
              final fecha = fechaController.text;
              final tipo = tipoController.text;

              final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);
              _currentPosition = position;
              final latitude = _currentPosition.latitude;
              final longitude = _currentPosition.longitude;

              try {
                String nombreArchivo = '';

                if (_selectedFile != null && _selectedFile!.path.isNotEmpty) {
                  final firebaseStorageRef = FirebaseStorage.instance
                      .ref()
                      .child('archivos')
                      .child(_selectedFile!.path.split('/').last);

                  await firebaseStorageRef.putFile(_selectedFile!);

                  nombreArchivo = _selectedFile!.path.split('/').last;
                }

                // Determinar la colección según el tipo de solicitud
                String collectionName = '';
                switch (tipo) {
                  case 'Peticion':
                    collectionName = 'peticiones';
                    break;
                  case 'Queja':
                    collectionName = 'quejas';
                    break;
                  case 'Reclamo':
                    collectionName = 'reclamos';
                    break;
                  case 'Vivencia':
                    collectionName = 'vivencias';
                    break;
                  default:
                    collectionName = 'otras';
                }

                await FirebaseFirestore.instance.collection(collectionName).add({
                  'descripcion': descripcion,
                  'estado': estado,
                  'fecha': fecha,
                  'tipo': tipo,
                  'latitude': latitude,
                  'longitude': longitude,
                  'nombreArchivo': nombreArchivo,
                });

                descripcionController.clear();
                estadoController.clear();
                fechaController.clear();
                tipoController.clear();
                _selectedFile = null;

                // Después de agregar un nuevo elemento, cerrar la pantalla actual y refrescar la pantalla de inicio
                Navigator.pop(context, true);
              } catch (error) {
                print('Error al guardar en Firestore: $error');
              }
            },
            child: Text('Añadir a la lista'),
          ),
        ],
      ),
    );
  }
}
