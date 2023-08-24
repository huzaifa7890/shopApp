import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  CartItem({this.id, this.price, this.quantity, this.title});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalamt {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void additem(String productid, double price, String title) {
    if (_items.containsKey(productid)) {
      _items.update(
        productid,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productid,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeitem(String productid) {
    _items.remove(productid);
    notifyListeners();
  }

  void removesingleitem(String proid) {
    if (!_items.containsKey(proid)) {
      return;
    }
    if (_items[proid].quantity > 1) {
      _items.update(
          proid,
          (existingcartitem) => CartItem(
                id: existingcartitem.id,
                title: existingcartitem.title,
                price: existingcartitem.price,
                quantity: existingcartitem.quantity - 1,
              ));
    } else {
      _items.remove(proid);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
