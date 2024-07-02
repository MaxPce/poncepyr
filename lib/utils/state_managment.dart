import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getPeticiones() async {
  List<Map<String, dynamic>> solicitudes = [];

  // Obtenemos las solicitudes de la colección "peticiones"
  QuerySnapshot queryPeticiones =
      await FirebaseFirestore.instance.collection('peticiones').get();

  for (var doc in queryPeticiones.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> solicitud = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": "Peticion",
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "uid": doc.id,
    };

    solicitudes.add(solicitud);
  }

  // Obtenemos las solicitudes de la colección "vivencias"
  QuerySnapshot queryVivencias =
      await FirebaseFirestore.instance.collection('vivencias').get();

  for (var doc in queryVivencias.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> solicitud = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": "Vivencia", // Indicamos el tipo de solicitud
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "uid": doc.id,
    };

    solicitudes.add(solicitud);
  }

  // Obtenemos las solicitudes de la colección "quejas"
  QuerySnapshot queryQuejas =
      await FirebaseFirestore.instance.collection('quejas').get();

  for (var doc in queryQuejas.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> solicitud = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": "Queja", // Indicamos el tipo de solicitud
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "uid": doc.id,
    };

    solicitudes.add(solicitud);
  }

  // Obtenemos las solicitudes de la colección "reclamos"
  QuerySnapshot queryReclamos =
      await FirebaseFirestore.instance.collection('reclamos').get();

  for (var doc in queryReclamos.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> solicitud = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": "Reclamo", // Indicamos el tipo de solicitud
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "uid": doc.id,
    };

    solicitudes.add(solicitud);
  }

  return solicitudes;
}
Future<List<Map<String, dynamic>>> getPeticionPorTipo(String tipoSolicitud) async {
  List<Map<String, dynamic>> peticiones = [];
  String collectionName = '';

  switch (tipoSolicitud) {
    case 'Peticion':
      collectionName = 'peticiones';
      break;
    case 'Queja':
      collectionName = 'quejas';
      break;
    case 'Reclamo':
      collectionName = 'reclamos';
      break;
    case 'Vivencia':
      collectionName = 'vivencias';
      break;
    default:
      return [];
  }

  QuerySnapshot querySolicitudes = await FirebaseFirestore.instance.collection(collectionName).get();

  for (var doc in querySolicitudes.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> solicitud = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": data["tipo"],
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "uid": doc.id,
    };

    peticiones.add(solicitud);
  }

  return peticiones;
}







Future<void> addPeticion(
    String descripcion, String estado, String fecha, String tipo) async {
  await db.collection("peticiones").add({
    "descripcion": descripcion,
    "estado": estado,
    "fecha": fecha,
    "tipo": tipo,
  });
}

Future<void> updatePeticion(String uid, String descripcion, String estado,
    String fecha, String tipo,String latitude, String longitude) async {
  await db.collection("peticiones").doc(uid).set({
    "descripcion": descripcion,
    "estado": estado,
    "fecha": fecha,
    "tipo": tipo,
    "latitude": latitude,
    "longitude": longitude,
  });
}

Future<void> deletePeticion(String uid) async {
  await db.collection("peticiones").doc(uid).delete();
}

@immutable
class CartItem {
  int? id;
  final String descripcion;
  final String estado;
  final String fecha;
  final String tipo;

  CartItem({
    this.id,
    required this.descripcion,
    required this.estado,
    required this.fecha,
    required this.tipo,
  });

  CartItem copyWith({
    int? id,
    String? descripcion,
    String? estado,
    String? fecha,
    String? tipo,
  }) {
    return CartItem(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
    );
  }
}

var cartList = List<CartItem>.empty();

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(cartList);
  int _idCounter = 0;
  int _generateUniqueID() {
    _idCounter++;
    return _idCounter;
  }

  void add(CartItem item) {
    final uniqueID = _generateUniqueID();
    item.id = uniqueID;
    state = [...state, item];
  }

  void toggle(int itemId) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith() else item,
    ];
  }

  int countTotalItems() {
    return state.length;
  }
}

final cartListProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

var menuItems = [
  'Activa',
  'En Espera',
  'Inactiva',
];

final menuProvider = StateProvider<String>((ref) {
  return 'Inactiva';
});

final filteredCartListProvider = Provider<List<CartItem>>((ref) {
  final filter = ref.watch(menuProvider);
  final estadoFilter = ref.watch(estadoControllerProvider);
  final tipoFilter = ref.watch(tipoControllerProvider);
  final cartList = ref.watch(cartListProvider) ?? [];

  switch (filter) {
    case 'Activa':
      return cartList
          .where((item) =>
              item.estado == 'Activa' &&
              item.tipo == tipoFilter &&
              (estadoFilter.isEmpty || item.estado.contains(estadoFilter)))
          .toList();
    case 'En Espera':
      return cartList
          .where((item) =>
              item.estado == 'En Espera' &&
              item.tipo == tipoFilter &&
              (estadoFilter.isEmpty || item.estado.contains(estadoFilter)))
          .toList();
    case 'Inactiva':
      return cartList
          .where((item) =>
              item.estado == 'Inactiva' &&
              item.tipo == tipoFilter &&
              (estadoFilter.isEmpty || item.estado.contains(estadoFilter)))
          .toList();
  }

  throw Exception("Invalid filter state");
});

final estadoControllerProvider = StateProvider<String>((ref) => '');
final tipoControllerProvider = StateProvider<String>((ref) => '');
