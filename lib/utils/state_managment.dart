import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getPeticion() async {
  List peticiones = [];
  QuerySnapshot queryPeticiones = await db.collection('peticiones').get();

  for (var doc in queryPeticiones.docs) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    Map peticion = {
      "descripcion": data["descripcion"],
      "estado": data["estado"],
      "fecha": data["fecha"],
      "tipo": data["tipo"],
      "uid": doc.id,
    };

    peticiones.add(peticion);
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
    String fecha, String tipo) async {
  await db.collection("peticiones").doc(uid).set({
    "descripcion": descripcion,
    "estado": estado,
    "fecha": fecha,
    "tipo": tipo,
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
