import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../screens/user_product_edit_screen.dart';

class UserProductItemWidget extends StatelessWidget {
  const UserProductItemWidget(
      {Key? key, required this.productTitle, required this.imageUrl, required this.productId})
      : super(key: key);

  final String productId;
  final String productTitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(productTitle),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(UserProductEditScreen.routeName, arguments: productId);
            },
            icon: const Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
              onPressed: () async{
                try{
                  await Provider.of<ProductsProvider>(context, listen: false).deleteProduct(productId);
                 // final product = productData.getProductById(productId);
                 // productData.deleteProduct(product.id);
                  Get.snackbar(
                    "Product deleted!",
                    "",
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 1),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    margin: const EdgeInsets.all(15),
                  );
                }catch(error){
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text("an error occurred!"),
                          content: Text(error.toString()),
                          actions: [
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.check))
                          ],
                        );
                      });
                }

              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor),
        ],
      ),
    );
  }
}
