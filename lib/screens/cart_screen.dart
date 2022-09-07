import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    //final orders = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('your cart'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "total: ",
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      "total: Rs:  ${cart.totalAmount}",
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderButtonWidget(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cart.carItemCount,
                itemBuilder: (context, index) => CardItemWidget(
                    price: cart.cartItems.values.toList()[index].price,
                    productId: cart.cartItems.keys.toList()[index],
                    title: cart.cartItems.values.toList()[index].title,
                    quantity: cart.cartItems.values.toList()[index].quantity,
                    id: cart.cartItems.values.toList()[index].id)),
          )
        ],
      ),
    );
  }
}

class OrderButtonWidget extends StatefulWidget {
  const OrderButtonWidget({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final CartProvider cart;

  @override
  State<OrderButtonWidget> createState() => _OrderButtonWidgetState();
}

class _OrderButtonWidgetState extends State<OrderButtonWidget> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading ? const CircularProgressIndicator():TextButton(
      //disabling the button if cart is empty
        onPressed: (widget.cart.totalAmount <= 0 || isLoading) ? null:() async {
          //here have set listen to false because we do not want to listen to any change
          //we just want to fire a method here i.e addOrder()
          setState((){
            isLoading = true;
          });
          await Provider.of<OrderProvider>(context, listen: false)
              .addOrder(widget.cart.cartItems.values.toList(),
                  widget.cart.totalAmount);
          setState((){
            isLoading = false;
          });

          //Navigator.pushNamed(context, OrdersScreen.routeName);

          //method to clear the cart after order is ordered
          widget.cart.clearCart();
        },
        child: const Text("ORDER NOW"));
  }
}
