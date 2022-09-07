import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/*provider for single products - helps widgets listen when there is a change to a single product*/
class ProductProvider extends ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFavourite;

  ProductProvider(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  void toggleFavourite(String token, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();

    final url = Uri.parse(
        'https://shop-app-flutter-e4866-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavourite,
          ));
      if(response.statusCode >= 400){
        //roll back to old status if failed
        isFavourite = oldStatus;
        notifyListeners();
      }
    }
    catch (error) {
      //roll back to old status if failed
      isFavourite = oldStatus;
      notifyListeners();
    }
  }

// isFavourite = !isFavourite;
/*if (isFavourite == false) {
      isFavourite = true;
    } else {
      isFavourite = false;
    }*/

}
