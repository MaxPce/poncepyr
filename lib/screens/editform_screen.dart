import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/utils/state_managment.dart';

class EditItem extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _EditItemState();
}

class _EditItemState extends ConsumerState<EditItem> {
  final TextEditingController descripcionController =
      TextEditingController(text: "");
  final TextEditingController estadoController =
      TextEditingController(text: "");
  final TextEditingController fechaController = TextEditingController(text: "");
  final TextEditingController tipoController = TextEditingController(text: "");

  @override
  void initState() {
    descripcionController.text = widget.currentDescripcion;
    estadoController.text = widget.currentEstado;
    fechaController.text = widget.currentFecha;
    tipoController.text = widget.currentTipo;

    super.initState();
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
                    await deletePeticion(widget.uid);
                    Navigator.of(context).pop();
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
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualizar automáticamente la fecha
                final currentDate = DateTime.now();
                final formattedDate =
                    "${currentDate.day}/${currentDate.month}/${currentDate.year}";
                fechaController.text = formattedDate;

                await updatePeticion(
                  widget.uid,
                  descripcionController.text,
                  estadoController.text,
                  fechaController.text,
                  tipoController.text,
                ).then((_) {
                  Navigator.pop(context);
                });
              },
              child: const Text("Actualizar"),
            )
          ],
        ),
      ),
    );
  }
}
