import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  //declaring route name so that we can use to register the route in main
  static const routeName = '/product-detail-screen';

  @override
  Widget build(BuildContext context) {
    /*extracting the ID that we forwarded on named route from product grid screen
    * so that we can access the required arguments by using that id such as title, price etc..*/
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    final loadedProduct = Provider.of<ProductsProvider>(context)
        .getProducts()
        .firstWhere((element) => element.id == productId);
    //final productItem = productProviderObject.getProducts();

    return Scaffold(
      appBar: AppBar(title: Text(loadedProduct.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image(
                  image: NetworkImage(loadedProduct.imageUrl),
                  fit: BoxFit.cover),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Rs: ${loadedProduct.price}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true ,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
