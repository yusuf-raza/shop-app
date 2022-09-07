import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item_widget.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({
    Key? key, required this.isFavourite,
  }) : super(key: key);

  final bool isFavourite;

  @override
  Widget build(BuildContext context) {
    // we are establishing a connection between our ProductsProvider provider
    //and the widget in which we want to use the provided data
    //creating an object of the provider
    final productsObject = Provider.of<ProductsProvider>(context);
    //using the getter to access the getProducts method that we created
    //we have applied logic to show only those products that are favourite or vice versa
    final productItems = isFavourite ? productsObject.getFavouriteProducts() : productsObject.getProducts();


    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: productItems.length,
        //how grid is structured--how many columns should it have
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 2),
        itemBuilder: (context, index) => ChangeNotifierProvider.value(
              //create: (BuildContext context) => productItems[index],

              /*previously, we were using ChangeNotifierProvider() constructor of provider (when we were instantiating the ProductsProvider()),
              * but when you provide the data to a Scrollable List, or Grid (where the widgets are recycled)
              * there is a chance that when the sate of app gets more complicated with more data and screens
              * , it will cause bugs, so we have changed the ChangeNotifierProvider() to ChangeNotifierProvider().value
              * constructor in here (because we are not creating a new Provider instance), this new constructor takes the relevant provider class in value: attribute instead
              * of a builder as in ChangeNotifierProvider()*/

              value: productItems[index],
              child:const ProductItem(),
            ));
  }
}
