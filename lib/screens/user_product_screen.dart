import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/user_product_edit_screen.dart';
import 'package:shop_app/widgets/app_drawer_widget.dart';
import 'package:shop_app/widgets/user_product_item_widget.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key? key}) : super(key: key);

  static const routeName = '/user-products-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetData(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<ProductsProvider>(context);
    //final productItems = productsData.getProducts();



    //print('looop');

    return Scaffold(
      appBar: AppBar(
        title: const Text('your products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(UserProductEditScreen.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const AppDrawerWidget(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ?  Center(child: JumpingDotsProgressIndicator(
              fontSize: 40,
            ))
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    //return Provider.of<ProductsProvider>(context,listen: false).fetchAndSetData(true);

                    child: Consumer<ProductsProvider>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: productsData.getProducts().length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Card(
                                    elevation: 3,
                                    child: UserProductItemWidget(
                                        productId: productsData.getProducts()[index].id,
                                        productTitle: productsData.getProducts()[index].title,
                                        imageUrl: productsData.getProducts()[index].imageUrl),
                                  ),
                                  //const Divider()
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }
}
