import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UsuarioConRool {
  final User user;
  String? rool;

  UsuarioConRool(this.user, {this.rool});
}

extension UserExtension on User {
  UsuarioConRool withRool(String? rool) {
    return UsuarioConRool(this, rool: rool);
  }
}

class UsuariosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: FutureBuilder(
        future: getUser(),
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
              child: Text('Usuario no encontrado'),
            );
          } else {
            UsuarioConRool usuario = snapshot.data as UsuarioConRool;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text(usuario.user.email ?? 'No disponible'),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Rol'),
                  subtitle: Text(usuario.rool ?? 'No disponible'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<UsuarioConRool> getUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Si el usuario está autenticado, obtener su rol desde Firestore
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Si el documento existe, actualizar el rol del usuario
      if (documentSnapshot.exists) {
        String? rool = documentSnapshot['rool'];
        return user.withRool(rool);
      }
    }

    return UsuarioConRool(user!); // Si no se encuentra el usuario, retornar el usuario sin rol.
  }
}