import 'package:app_admin/screens/addform_socio_screen.dart';
import 'package:app_admin/screens/configuration_screen.dart';
import 'package:app_admin/screens/editform_socio_screen.dart';
import 'package:app_admin/utils/state_managment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/screens/seguimiento_screen.dart';
import 'login.dart';

class Socio extends ConsumerWidget {
  const Socio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dropDownValue = ref.watch(menuProvider);
    String estadoFilter = ref.watch(estadoControllerProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Sistema de Solicitudes'),
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
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
          ],
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 16.0),
            unselectedLabelStyle: TextStyle(fontSize: 14.0),
            labelColor: Color.fromRGBO(0, 0, 0, 1),
            unselectedLabelColor: Color.fromRGBO(128, 128, 128, 1),
            tabs: [
              Tab(text: 'Peticiones'),
              Tab(text: 'Quejas'),
              Tab(text: 'Reclamos'),
              Tab(text: 'Vivencias'),
            ],
          ),
        ),
        drawer: _buildDrawer(context),
        body: TabBarView(
          children: [
            _buildSolicitudes(ref, 'Peticion', estadoFilter),
            _buildSolicitudes(ref, 'Queja', estadoFilter),
            _buildSolicitudes(ref, 'Reclamo', estadoFilter),
            _buildSolicitudes(ref, 'Vivencia', estadoFilter),
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

  Widget _buildSolicitudes(WidgetRef ref, String tipoSolicitud, String estadoFilter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: getPeticionPorTipo(tipoSolicitud),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
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
                          currentDescripcion: responseData[index]['descripcion'].toString(),
                          currentEstado: responseData[index]['estado'].toString(),
                          currentFecha: responseData[index]['fecha'].toString(),
                          currentTipo: responseData[index]['tipo'].toString(),
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: CheckboxListTile(
                      title: Text(responseData[index]['descripcion'].toString()),
                      value: responseData[index]['inCart'] ?? false,
                      onChanged: (value) {
                        if (responseData[index]['uid'] != null) {
                          ref.read(cartListProvider.notifier).toggle(responseData[index]['uid']);
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
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Center(
                    child: Text('Error al cargar datos'),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                var userData = snapshot.data!;
                String role = userData['rool'] ?? 'No especificado';
                return UserAccountsDrawerHeader(
                  accountName: user != null ? Text(user.displayName ?? '') : null,
                  accountEmail: user != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email ?? ''),
                            Text('Rol: $role'),
                          ],
                        )
                      : null,
                  currentAccountPicture: user != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                          child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                        )
                      : null,
                );
              } else {
                return DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Center(
                    child: Text('No hay datos disponibles'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Solicitudes'),
            onTap: () {
              Navigator.pop(context);
              DefaultTabController.of(context)?.animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Seguimiento'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeguimientoScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionesScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfigurationScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}


class NotificacionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: List.generate(10, (index) {
          return Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(
                Icons.notification_important,
                color: Colors.red.shade700,
              ),
              title: Text('Notificación ${index + 1}'),
              subtitle: Text('Esta es la descripción de la notificación ${index + 1}.'),
            ),
          );
        }),
      ),
    );
  }
}

