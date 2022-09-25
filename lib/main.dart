import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:shop_app/screens/user_product_edit_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';
import 'package:shop_app/utils/themes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*we are registering ChangeNotifierProvider here in the MyApp widget
    * because the screen in which we are going to listen for change notifier is ProductsOverviewScreen
    * and it is the direct child of MyApp*/

    /*
    * ChangeNotifierProvider(
      //the create attribute receives an instance of the provider which we want to use - create is same as builder
      create: (BuildContext context) => ProductsProvider() ,*/

    /*now since we are using multiple providers, so instead of nesting the providers,
    * we are using MultiProvider at the root level that takes a list of all the provider*/
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (BuildContext context) => AuthProvider()),
          ChangeNotifierProvider(
              //value: ProductsProvider(),
              create: (BuildContext context) => ProductsProvider(
                  Provider.of<AuthProvider>(context, listen: false)
                      .token
                      .toString(),
                  Provider.of<AuthProvider>(context, listen: false).userId!)),
          ChangeNotifierProvider(
              //value: CartProvider(),
              create: (BuildContext context) => CartProvider()),
          ChangeNotifierProvider(
              create: (BuildContext context) => OrderProvider(
                  Provider.of<AuthProvider>(context, listen: false)
                      .token
                      .toString(),
                  Provider.of<AuthProvider>(context, listen: false)
                      .userId
                      .toString())),
        ],
        //wrapping material app in consumer so that we can rebuild this widget
        //depending on the user authentication status
        child: Consumer<AuthProvider>(
          builder: (context, authObject, _) => MaterialApp(
            title: "My Shop",
            //if user is authenticated then ProductsOverviewScreen will be displayed
            //otherwise AuthScreen will be displayed
            home: authObject.isAuth
                ? const ProductOverviewScreen()
                : const AuthScreen(),
            theme: MyAppTheme.myLightThemeData(context),
            //darkTheme: MyAppTheme.myDarkThemeData(context)

            routes: {
              ProductDetailScreen.routeName: (context) =>
                  const ProductDetailScreen(),
              CartScreen.routeName: (context) => const CartScreen(),
              OrdersScreen.routeName: (context) => const OrdersScreen(),
              UserProductScreen.routeName: (context) =>
                  const UserProductScreen(),
              UserProductEditScreen.routeName: (context) =>
                  const UserProductEditScreen(),
              AuthScreen.routeName: (context) => const AuthScreen(),
              ProductOverviewScreen.routeName: (context) =>
                  const ProductOverviewScreen()
            },
          ),
        ));
  }
}
