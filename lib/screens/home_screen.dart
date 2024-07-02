import 'package:flutter/material.dart';
import 'package:app_admin/screens/addform_screen.dart';
import 'package:app_admin/screens/editform_screen.dart';
import 'package:app_admin/screens/detail_screen.dart';
import 'package:app_admin/screens/usuarios_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/utils/state_managment.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dropDownValue = ref.watch(menuProvider);
    String estadoFilter = ref.watch(estadoControllerProvider);

    return DefaultTabController(
      length: 4, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Sistema de Solicitudes'),
          actions: [
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsuariosScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Solicitudes'),
              Tab(text: 'Reportes'),
              Tab(text: 'Usuarios'),
              Tab(text: 'Notificaciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSolicitudes(ref, 'Peticion', estadoFilter),
            // Añade aquí los widgets para 'Reportes', 'Reportes Gráficos' y 'Notificaciones'
            Center(child: Text('Reportes')), // Ejemplo de vista para 'Reportes'
            Center(child: Text('Usuarios')),
            Center(child: Text('Notificaciones')), // Ejemplo de vista para 'Notificaciones'
          ],
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
      ),
    );
  }

  Widget _buildSolicitudes(
      WidgetRef ref, String tipoSolicitud, String estadoFilter) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: getPeticiones(),
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
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                uid: responseData[index]['uid'].toString(),
                                descripcion: responseData[index]['descripcion'].toString(),
                                estado: responseData[index]['estado'].toString(),
                                tipoSolicitud: tipoSolicitud,
                                latitude: responseData[index]['latitude'].toString(),
                                longitude: responseData[index]['longitude'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(responseData[index]['descripcion'].toString()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Estado: ${responseData[index]['estado']}'),
                                Text('Latitude: ${responseData[index]['latitude']}'),
                                Text('Longitude: ${responseData[index]['longitude']}'),
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
        ],
      ),
    );
  }
}
