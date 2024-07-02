import 'package:app_admin/screens/configuration_screen.dart';
import 'package:app_admin/screens/graficos_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_admin/screens/addform_screen.dart';
import 'package:app_admin/screens/editform_screen.dart';
import 'package:app_admin/screens/seguimiento_screen.dart';
import 'package:app_admin/screens/detail_screen.dart';
import 'package:app_admin/screens/usuarios_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_admin/utils/state_managment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:async/async.dart';


class Administrador extends StatefulWidget {
  const Administrador({Key? key}) : super(key: key);

  @override
  _AdministradorState createState() => _AdministradorState();
}

class _AdministradorState extends State<Administrador> {
  int _selectedIndex = 0;
  User? _user; // Variable para almacenar la información del usuario
  String? _userRool; // Variable para almacenar el rol del usuario

  static List<Widget> _screens = [
    SolicitudesScreen(),
    SeguimientoScreen(), // Añade la pantalla de seguimiento
    NotificacionesScreen(),
    UsuariosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Obtener información del usuario al inicializar el estado
  }

  void _getUserInfo() async {
    _user = FirebaseAuth.instance.currentUser; // Obtener el usuario actualmente autenticado
    if (_user != null) {
      // Obtener el documento del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      setState(() {
        _userRool = userDoc['rool']; // Obtener el rol del usuario
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Cierra el drawer después de la selección
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Sistema de Solicitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: _user != null ? Text(_user!.displayName ?? '') : null,
            accountEmail: _user != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_user!.email ?? ''),
                      Text('Rol: ${_userRool ?? 'No especificado'}'),
                    ],
                  )
                : null,
            currentAccountPicture: _user != null
                ? CircleAvatar(
                    radius: 50, // Aumentar el tamaño del avatar
                    backgroundColor: Colors.transparent,
                    backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                    child: _user!.photoURL == null ? Icon(Icons.person, size: 50) : null,
                  )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Solicitudes'),
            onTap: () => _onItemTapped(0),
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Seguimiento'),
            onTap: () => _onItemTapped(1),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            onTap: () => _onItemTapped(2),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            onTap: () => _onItemTapped(3),
          ),
          ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Gráficos'),
          onTap: () {
            Navigator.pop(context);
            // Navegar a la pantalla de gráficos
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraficosScreen(), // Asegúrate de tener esta pantalla implementada
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



class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  _SolicitudesScreenState createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getSolicitudes(),
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
              Map<String, List<dynamic>> responseData = snapshot.data as Map<String, List<dynamic>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _search(),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: responseData.length,
                    itemBuilder: (context, index) {
                      String tipoSolicitud = responseData.keys.elementAt(index);
                      List<dynamic> solicitudes = _filterSolicitudes(responseData[tipoSolicitud]!);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              tipoSolicitud,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        uid: solicitudes[index]['uid'].toString(),
                                        descripcion: solicitudes[index]['descripcion'].toString(),
                                        estado: solicitudes[index]['estado'].toString(),
                                        tipoSolicitud: tipoSolicitud,
                                        latitude: solicitudes[index]['latitude'].toString(),
                                        longitude: solicitudes[index]['longitude'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  color: Theme.of(context).cardTheme.color,
                                  shadowColor: Theme.of(context).cardTheme.shadowColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          solicitudes[index]['descripcion'].toString(),
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Estado: ${solicitudes[index]['estado']}',
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                        Text(
                                          'Latitude: ${solicitudes[index]['latitude']}',
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                        Text(
                                          'Longitude: ${solicitudes[index]['longitude']}',
                                          style: Theme.of(context).textTheme.bodyText2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(
                              height: 8,
                            ),
                            itemCount: solicitudes.length,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _search() {
    setState(() {});
  }

  List<dynamic> _filterSolicitudes(List<dynamic> solicitudes) {
    String searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return solicitudes;
    }
    return solicitudes.where((solicitud) {
      String descripcion = solicitud['descripcion'].toString().toLowerCase();
      return descripcion.contains(searchText);
    }).toList();
  }

  Future<Map<String, List<dynamic>>> getSolicitudes() async {
    Map<String, List<dynamic>> solicitudes = {
      'Peticiones': [],
      'Quejas': [],
      'Reclamos': [],
      'Vivencias': [],
    };

    // Obtener todas las solicitudes
    List<Map<String, dynamic>> peticiones = await getPeticionPorTipo('Peticion');
    List<Map<String, dynamic>> quejas = await getPeticionPorTipo('Queja');
    List<Map<String, dynamic>> reclamos = await getPeticionPorTipo('Reclamo');
    List<Map<String, dynamic>> vivencias = await getPeticionPorTipo('Vivencia');

    // Agregarlas a la lista correspondiente
    solicitudes['Peticiones'] = peticiones;
    solicitudes['Quejas'] = quejas;
    solicitudes['Reclamos'] = reclamos;
    solicitudes['Vivencias'] = vivencias;

    return solicitudes;
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


class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por correo',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No hay usuarios disponibles'),
                  );
                } else {
                  var users = snapshot.data!.docs;
                  var filteredUsers = users.where((user) {
                    String email = user['email'] ?? '';
                    return email.toLowerCase().contains(_searchText.toLowerCase());
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        color: Theme.of(context).cardTheme.color,
                        shadowColor: Theme.of(context).cardTheme.shadowColor,
                        child: ListTile(
                          title: Text(
                            user['email'] ?? 'Correo no disponible',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          subtitle: Text(
                            user['rool'] ?? 'Rool no disponible',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                      );
                    },
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