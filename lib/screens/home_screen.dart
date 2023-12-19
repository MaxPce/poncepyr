import 'package:app_admin/screens/addform_screen.dart';
import 'package:app_admin/utils/state_managment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/screens/editform_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalItems = ref.read(cartListProvider.notifier).countTotalItems();
    String dropDownValue = ref.watch(menuProvider);
    String estadoFilter = ref.watch(estadoControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Sistema de Reportes'),
        actions: [
          DropdownButton(
            style: const TextStyle(color: Colors.white),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            value: dropDownValue,
            items: menuItems
                .map((String e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (String? value) => ref
                .read(menuProvider.notifier)
                .update((state) => state = value!),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getPeticion(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text('No hay datos disponibles'),
              );
            } else {
              List<dynamic> responseData = snapshot.data as List<dynamic>;
              return ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return EditItem(
                            uid: responseData[index]['uid'].toString(),
                            currentDescripcion:
                                responseData[index]['descripcion'].toString(),
                            currentEstado:
                                responseData[index]['estado'].toString(),
                            currentFecha:
                                responseData[index]['fecha'].toString(),
                            currentTipo: responseData[index]['tipo'].toString(),
                          );
                        },
                      );
                    },
                    child: Card(
                      elevation: 2,
                      child: CheckboxListTile(
                        title: Text(
                          responseData[index]['descripcion'].toString(),
                        ),
                        value: responseData[index]['inCart'] ?? false,
                        onChanged: (value) {
                          if (responseData[index]['uid'] != null) {
                            ref
                                .read(cartListProvider.notifier)
                                .toggle(responseData[index]['uid']);
                          }
                        },
                        secondary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: ${responseData[index]['estado']}'),
                            Text('Fecha: ${responseData[index]['fecha']}'),
                            Text('Tipo: ${responseData[index]['tipo']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 8,
                ),
                itemCount: responseData.length,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) {
            return AddItem();
          },
        ),
      ),
    );
  }
}
