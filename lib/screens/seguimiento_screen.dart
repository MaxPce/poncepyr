import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeguimientoScreen extends StatefulWidget {
  @override
  _SeguimientoScreenState createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento de Solicitudes'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSolicitudesStream('peticiones', Colors.blue),
              _buildSolicitudesStream('quejas', Colors.red),
              _buildSolicitudesStream('vivencias', Colors.green),
              _buildSolicitudesStream('reclamos', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudesStream(String tipoSolicitud, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(tipoSolicitud)
          .where('estado', whereIn: ['Activa', 'Inactiva'])
          .where('respuesta', isNotEqualTo: '')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar las solicitudes'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container();
        }

        final solicitudes = snapshot.data!.docs;

        return Card(
          margin: EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitudes de $tipoSolicitud',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final solicitud = solicitudes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text('Descripción: ${solicitud['descripcion']}'),
                        subtitle: Text('Estado: ${solicitud['estado']}'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => _mostrarDetalleSolicitud(solicitud),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetalleSolicitud(DocumentSnapshot solicitud) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle de la Solicitud'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('Descripción', solicitud['descripcion']),
                _buildDetailItem('Estado', solicitud['estado']),
                _buildDetailItem('Tipo de Solicitud', solicitud.reference.parent!.id),
                _buildDetailItem('Respuesta', solicitud['respuesta']),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }

  void _mostrarEvidencia(String evidencia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Evidencia'),
          content: Image.network(evidencia),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
