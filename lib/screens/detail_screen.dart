import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data'; 

class DetailScreen extends StatefulWidget {
  final String uid;
  final String descripcion;
  final String estado;
  final String tipoSolicitud;
  final String latitude;
  final String longitude;
  final Uint8List? evidencia; 

  const DetailScreen({
    Key? key,
    required this.uid,
    required this.descripcion,
    required this.estado,
    required this.tipoSolicitud,
    required this.latitude,
    required this.longitude,
    this.evidencia, // Cambiado de String a Uint8List
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController respuestaController;
  late String nuevoEstado;
  late bool solucionado;

  @override
  void initState() {
    super.initState();
    respuestaController = TextEditingController();
    nuevoEstado = widget.estado;
    solucionado = false;
  }

  @override
  void dispose() {
    respuestaController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Solicitud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Descripción', widget.descripcion),
            _buildDetailItem('Estado', widget.estado),
            _buildDetailItem('Tipo de Solicitud', widget.tipoSolicitud),
            _buildDetailItem('Latitude', widget.latitude),
            _buildDetailItem('Longitude', widget.longitude),
            
            _buildDownloadButton(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mostrarFormulario,
              child: Text('Responder y Cambiar Estado'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDownloadButton() {
    return Visibility(
      visible: widget.evidencia != null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          onPressed: _descargarEvidencia,
          icon: Icon(Icons.download),
          label: Text('Descargar Evidencia'),
        ),
      ),
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

  void _mostrarFormulario() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Responder y Cambiar Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: respuestaController,
                decoration: InputDecoration(
                  labelText: 'Respuesta',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: nuevoEstado,
                onChanged: (value) {
                  setState(() {
                    nuevoEstado = value!;
                  });
                },
                items: ['Activa', 'En Espera', 'Inactiva']
                    .map((estado) => DropdownMenuItem<String>(
                          value: estado,
                          child: Text(estado),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Cambiar Estado',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('¿Se solucionó la solicitud?'),
                  SizedBox(width: 10),
                  DropdownButton<bool>(
                    value: solucionado,
                    onChanged: (value) {
                      setState(() {
                        solucionado = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Sí'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('No'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _enviarRespuestaYCambiarEstado,
              child: Text('Enviar'),  
            ),
          ],
        );
      },
    );
  }

  void _enviarRespuestaYCambiarEstado() {
    String respuesta = respuestaController.text.trim();
    FirebaseFirestore.instance.collection(widget.tipoSolicitud.toLowerCase()).doc(widget.uid).update({
      'respuesta': respuesta,
      'estado': nuevoEstado,
      'solucionado': solucionado,
    }).then((value) {
      Navigator.of(context).pop(); // Cerrar el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Respuesta enviada y estado cambiado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la respuesta y cambiar el estado: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _descargarEvidencia() {
    if (widget.evidencia != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Evidencia'),
            content: Image.memory(widget.evidencia!),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay evidencia disponible para descargar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
