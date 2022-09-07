import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'cart_provider.dart';

class OrderItem {
  final String id;
  final int amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem(
      {required this.dateTime,
      required this.id,
      required this.amount,
      required this.products});
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  OrderProvider(this.authToken, this.userId);



  //getter to get ls\ist of orders
  get orderItems {
    return [..._orders];
  }

  int orderItemsCount() {
    return _orders.length;
  }

  Future<void> fetchAndSetOrders() async {
    print(authToken);
    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');

    final List<OrderItem> loadedOrders = [];
    final response = await http.get(url);

    try {
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            dateTime: DateTime.parse(orderData['dateTime']),
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((cartItem) => CartItem(
                    title: cartItem['title'],
                    id: orderId,
                    price: cartItem['price'],
                    quantity: cartItem['quantity']))
                .toList()));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (_) {
      return;
    }
  }

  //method to add order
  Future<void> addOrder(List<CartItem> cartProducts, int totalAmount) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': totalAmount,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cartItem) => {
                      'id': cartItem.id,
                      'price': cartItem.price,
                      'title': cartItem.title,
                      'quantity': cartItem.quantity
                    })
                .toList()
          }));

      _orders.insert(
          0,
          OrderItem(
              dateTime: timeStamp,
              id: json.decode(response.body)['name'],
              amount: totalAmount,
              products: cartProducts));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
