import 'package:flutter/material.dart';
import 'dart:convert';
import 'product.dart';
import 'package:http/http.dart' as http;
import '../models/HttpException.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items {
    // if (_ShowFavorite) {
    //   return _items.where((proditem) => proditem.isFavorite).toList();
    // }
    return [..._items];
  }

  final authToken;
  final userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get showfav {
    return _items.where((proditem) => proditem.isFavorite).toList();
  }
  // void showfavoriteonly() { other metrhod we will use
  //   _ShowFavorite = true;
  //   notifyListeners();
  // }

  // void showsall() {
  //   _ShowFavorite = false;
  //   notifyListeners();
  // }

  Product findbyid(String id) {
    return _items.firstWhere((pro) => pro.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final stringFilter =
        filterByUser ? 'orderBy="createrId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$stringFilter');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final urll = Uri.parse(
          'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/userfavorite/$userId.json?auth=$authToken');

      final responseFavorite = await http.get(urll);
      final favdata = jsonDecode(responseFavorite.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favdata == null ? false : favdata[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'createrId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://firstproject-dcde3-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
