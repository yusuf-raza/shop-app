import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer_widget.dart';

import '../widgets/product_grid_widget.dart';

//using enums for filter options
enum FilterOptions { showFavouriteProducts, showAllProducts }

/*converted this widget to stateful widget because in here, we want o manage the state of widget locally,
* ie.e we want to show products based on isFavourite filter in this widget only.
* if we wanted the isFavourite filter globally in ap then we would have used Providers instead*/

class ProductOverviewScreen extends StatefulWidget {

  const ProductOverviewScreen({Key? key}) : super(key: key);

  static const routeName = '/overview-screen';

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavouriteProductsOnly = false;
  var _isLoading = true;

  @override
  void initState(){
    try{
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndSetData()
          .then((value) => setState(() {
        _isLoading = false;
      }));
    }catch(error){
      /*showDialog(
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
          });*/
      rethrow;
    }finally{
      setState(() {
        _isLoading = false;
      });
    }

    // print(fetchedProductObject.fetchAndSetData());
    //fetchedProductObject.fetchAndSetData().then((_) => _isLoading = false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopp App'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartObject, child) {
              return Badge(
                badgeContent: Text(
                  cartObject.carItemCount.toString(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                animationType: BadgeAnimationType.scale,
                position: BadgePosition.topEnd(top: 5, end: 2),
                badgeColor: Theme.of(context).colorScheme.secondary,
                child: child,
              );
            },
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart)),
          ),
          PopupMenuButton(
              onSelected: (FilterOptions value) {
                setState(() {
                  if (value == FilterOptions.showFavouriteProducts) {
                    _showFavouriteProductsOnly = true;
                  } else {
                    _showFavouriteProductsOnly = false;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOptions.showFavouriteProducts,
                      child: Text("favourite products"),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.showAllProducts,
                      child: Text("all products"),
                    ),
                  ]),
        ],
      ),
      drawer: const AppDrawerWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(isFavourite: _showFavouriteProductsOnly),
    );
  }
}
