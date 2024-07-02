import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';

class EditItem extends StatefulWidget {
  final String uid;
  final String currentDescripcion;
  final String currentEstado;
  final String currentFecha;
  final String currentTipo;

  const EditItem({
    Key? key,
    required this.uid,
    required this.currentDescripcion,
    required this.currentEstado,
    required this.currentFecha,
    required this.currentTipo,
  }) : super(key: key);

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  late Position _currentPosition;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    descripcionController.text = widget.currentDescripcion;
    estadoController.text = widget.currentEstado;
    fechaController.text = widget.currentFecha;
    tipoController.text = widget.currentTipo;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _updateItem() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    final descripcion = descripcionController.text;
    final estado = estadoController.text;
    final fecha = fechaController.text;
    final tipo = tipoController.text;
    final latitude = _currentPosition.latitude;
    final longitude = _currentPosition.longitude;

    try {
      String nombreArchivo = '';

      if (_selectedFile != null && _selectedFile!.path.isNotEmpty) {
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('imagenes')
            .child(_selectedFile!.path.split('/').last);

        await firebaseStorageRef.putFile(_selectedFile!);
        nombreArchivo = _selectedFile!.path.split('/').last;
      }

      await FirebaseFirestore.instance.collection('peticiones').doc(widget.uid).update({
        'descripcion': descripcion,
        'estado': estado,
        'fecha': fecha,
        'tipo': tipo,
        'latitude': latitude,
        'longitude': longitude,
        'nombreArchivo': nombreArchivo,
      });

      Navigator.pop(context, true); // Indicate that the item was updated
    } catch (error) {
      print('Error al actualizar en Firestore: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    fechaController.text = formattedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('peticiones')
                        .doc(widget.uid)
                        .delete();
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
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
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image, // Only allow image files
                );

                if (result != null) {
                  setState(() {
                    _selectedFile = File(result.files.single.path!);
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5), 
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedFile != null
                            ? _selectedFile!.path.split('/').last
                            : 'Seleccionar imagen',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateItem,
              child: const Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
