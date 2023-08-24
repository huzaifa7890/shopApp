import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';
import 'dart:convert';

class OrderItems {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItems({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItems> _orders = [];

  List<OrderItems> get orders {
    return [..._orders];
  }

  final authToken;
  final userId;
  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final responce = await http.get(url);
    final List<OrderItems> loadedOrder = [];
    final extratedData = json.decode(responce.body) as Map<String, dynamic>;
    if (extratedData == null) {
      return;
    }
    extratedData.forEach((orderID, orderData) {
      loadedOrder.add(OrderItems(
        id: orderID,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>)
            .map((items) => CartItem(
                  id: items['id'],
                  price: items['price'],
                  quantity: items['quantity'],
                  title: items['title'],
                ))
            .toList(),
      ));
    });
    _orders = loadedOrder.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    final responce = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItems(
        id: json.decode(responce.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
