import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: ListView(
          children: [
            const Image(image: AssetImage("assets/images/empty-cart.png")),
/*
            DrawerHeader(
                //curve: Curves.easeIn,
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://pbs.twimg.com/profile_images/1350086629264863233/ydwSLiHl_400x400.jpg"),
                    ),
                    accountName: Text("Yusuf Raza"),
                    accountEmail: Text("yusuf@gmail.com"))),
*/
            ListTile(
              leading: const Icon(Icons.shop, color: Colors.white),
              title: const Text('All products',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textScaleFactor: 1.2),
              onTap: () => Navigator.of(context).pushReplacementNamed('/'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.white),
              title: const Text('Your orders',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textScaleFactor: 1.2),
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Manage your products',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textScaleFactor: 1.2),
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(UserProductScreen.routeName),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  textScaleFactor: 1.2),
              onTap: () {
                // Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
                Provider.of<AuthProvider>(context, listen: false).logOut();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
