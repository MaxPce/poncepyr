import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/utils/state_managment.dart';

class AddItem extends ConsumerWidget {
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();

  AddItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener la fecha actual
    final currentDate = DateTime.now();
    final formattedDate =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";

    // Establecer la fecha actual en el controlador de fecha
    fechaController.text = formattedDate;
    estadoController.text = 'En Espera'; //
    tipoController.text = 'Peticion'; //
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          // Utilzar un DropdownButton para limitar las opciones de estado
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
          // Utilizar un DropdownButton para limitar las opciones de tipo
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
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              final descripcion = descripcionController.text;
              final estado = estadoController.text;
              final fecha = fechaController.text;
              final tipo = tipoController.text;

              if (descripcion.isNotEmpty &&
                  estado.isNotEmpty &&
                  fecha.isNotEmpty &&
                  tipo.isNotEmpty) {
                await addPeticion(descripcion, estado, fecha, tipo);

                // Limpiar campos
                descripcionController.clear();
                estadoController.clear();
                fechaController.clear();
                tipoController.clear();

                // Ocultar modal
                Navigator.of(context).pop();
              }
            },
            child: const Text('Añadir a la lista'),
          ),
        ],
      ),
    );
  }
}
