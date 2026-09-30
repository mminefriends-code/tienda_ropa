import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem({
    required ProductModel product,
    required String talla,
    required String color,
    required int idPtc,
    int cantidad = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.idPtc == idPtc || (item.nombre == product.nombre && item.talla == talla && item.color == color),
    );

    if (existingIndex >= 0) {
      _items[existingIndex].cantidad += cantidad;
    } else {
      _items.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch,
          idPtc: idPtc,
          nombre: product.nombre,
          talla: talla,
          color: color,
          precioUnitario: product.precioFinal,
          cantidad: cantidad,
          imagenUrl: product.imagenPrincipal,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].cantidad = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
