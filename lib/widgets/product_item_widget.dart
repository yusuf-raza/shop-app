
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import '../providers/product_provider.dart';

//this widget represents a grid item
class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);

  /*final String id;
  final String title;
  final String imageUrl;*/

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductProvider>(context);
    final cartProduct = Provider.of<CartProvider>(context, listen: false);
    final authObject = Provider.of<AuthProvider>(context);

    return Card(
      elevation: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
              leading: IconButton(
                onPressed: () {
                  product.toggleFavourite(authObject.token.toString(), authObject.userId!);
                },
                icon: Icon(product.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
              ),
              trailing: IconButton(
                onPressed: () {
                  //GetX snackbar code
                  /*Get.closeCurrentSnackbar();
                  Get.snackbar("added to cart!",
                      "",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 1),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                      margin: EdgeInsets.all(15),
                    isDismissible: true,
                    //dismissDirection: DismissDirection.horizontal,
                    //forwardAnimationCurve: Curves.easeOutBack,
                    //icon: Icon(Icons.person, color: Colors.white),
                    //onTap: (){}
                  );*/

                  cartProduct.addCartItem(
                      product.id, product.title, product.price);


                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('product added to cart!'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cartProduct.undoCartItem(product.id);
                        }),
                  ));
                },
                icon: const Icon(Icons.shopping_cart),
                color: Theme.of(context).colorScheme.secondary,
              ),
              backgroundColor: Colors.black87,
              title: Text(product.title, textAlign: TextAlign.center)),
          child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ProductDetailScreen.routeName,
                    arguments: product.id);
              },
              child: Image(
                  image: NetworkImage(product.imageUrl), fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
