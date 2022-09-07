import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/http_exceptions.dart';
import 'product_provider.dart';

/*provider for all products - helps widgets listen when there is a change to the list of products*/

class ProductsProvider with ChangeNotifier {
  List<ProductProvider> _items = [
    /*ProductProvider(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    ProductProvider(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    ProductProvider(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    ProductProvider(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this.userId);

//
  //a getter to access a copy of all the products
  //in the _items list
  //we have not returned the list _items itself,
  //instead we are returning a copy of it.
  // there are 2 reasons for this: 1) to save the original _items list from being accessed
  //2) to keep track of changes being made to products so we can add Listen for them

  //method to get all the products
  List<ProductProvider> getProducts() {
    return [..._items];
  }

  //method to get the favourite products only
  List<ProductProvider> getFavouriteProducts() {
    return _items.where((element) => element.isFavourite).toList();
  }

  ProductProvider getProductById(String productId) {
    final id = _items.indexWhere((element) => element.id == productId);

    return _items[id];
  }

  Future<void> updateProduct(String id, ProductProvider product) async {
    final index = _items.indexWhere((element) => element.id == id);

    if (index >= 0) {
      final url = Uri.parse(
          'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      try {
        await http.patch(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'image': product.imageUrl,
              'price': product.price,
            }));

        _items[index] = product;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('product could not be deleted!');
    } else {
      _items.removeWhere((element) => element.id == id);
      notifyListeners();
    }
    /*try {
      await http.delete(url);
     _items.removeWhere((element) => element.id == id);
      notifyListeners();

    } catch (error) {
      //throw HttpException('product could not be deleted!');
      rethrow;
    }*/
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url);
      final extractedData =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isNull) {
        return;
      }

      final favouriteUrl = Uri.parse(
          'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(favouriteUrl);
      final favouriteData = json.decode(favouriteResponse.body);

      final List<ProductProvider> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.insert(
            0,
            ProductProvider(
              description: value['description'],
              id: key,
              imageUrl: value['image'],
              isFavourite:
                  favouriteData == null ? false : favouriteData[key] ?? false,
              price: value['price'],
              title: value['title'],
            ));

        /*loadedProducts.add(ProductProvider(
          id: key,
          description: value['description'],
          imageUrl: value['image'],
          isFavourite: favouriteData == null ? false : favouriteData[key] ?? false,
          price: int.parse(value['price']),
          title: value['title'],
        ));*/

        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(url,
          body: json.encode({
            // 'id': DateTime.now().toString(),
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'image': product.imageUrl,
            'creatorId': userId
            // 'isFavourite': product.isFavourite
          }));

      final newProduct = ProductProvider(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
