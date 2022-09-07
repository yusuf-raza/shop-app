import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  //setting up a map to hold car items
   Map<String, CartItem> _cartItems = {};

  //getter to return a copy of cart items
  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  //getter to get cart length (cart items)
  int get carItemCount{
    return _cartItems.length;
  }

  int get totalAmount{
    int total = 0;
    _cartItems.forEach((price, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  //method to add an item to cart
  void addCartItem(String productId, String productTitle, int productPrice) {


    //id cartItem already exists, then we will just increase the quanitity
    if (_cartItems.containsKey(productId)) {
      //increase quantity
      _cartItems.update(
          productId,
          (existingCartItem) => CartItem(
              title: existingCartItem.title,
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1));
    }
    //else we will add item to the cart
    else {
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
              title: productTitle,
              id: DateTime.now().toString(),
              price: productPrice,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeCartItem(String productId){
    _cartItems.remove(productId);
    notifyListeners();
  }


  //this method removes the recent cart item
  void undoCartItem(String productId){
    if(!_cartItems.containsKey(productId)){
      return;
    }
    if(_cartItems[productId]!.quantity > 1){
      _cartItems.update(
          productId,
              (existingCartItem) => CartItem(
              title: existingCartItem.title,
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1));
    }else{
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  //this method is called to clear the cart items, after an order
  void clearCart(){
    _cartItems = {};
    notifyListeners();
  }
}

class CartItem {
  final int price;
  final int quantity;
  final String title;
  final String id;

  CartItem(
      {required this.title,
      required this.id,
      required this.price,
      required this.quantity});
}
