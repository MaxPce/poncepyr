import 'package:flutter/material.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Idioma'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para cambiar el idioma aquí
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Tema'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para cambiar el tema aquí
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Agrega la funcionalidad para activar/desactivar notificaciones aquí
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Seguridad'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para configurar la seguridad aquí
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Acerca de'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para mostrar información acerca de la aplicación aquí
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Enviar Comentarios'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para enviar comentarios aquí
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Ayuda'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Agrega la funcionalidad para mostrar la pantalla de ayuda aquí
            },
          ),
        ],
      ),
    );
  }
}