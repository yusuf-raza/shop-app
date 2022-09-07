import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';

class CardItemWidget extends StatelessWidget {
  const CardItemWidget(
      {Key? key,
      required this.price,
      required this.productId,
      required this.title,
      required this.quantity,
      required this.id})
      : super(key: key);

  final int price;
  final String title;
  final int quantity;
  final String productId;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (_) {
        Provider.of<CartProvider>(context, listen: false)
            .removeCartItem(productId);
      },
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(price.toString()),
            ),
            title: Text(title),
            subtitle: Text("Total: ${(price * quantity)}"),
            trailing: Text("Quanitity: $quantity"),
          ),
        ),
      ),
      confirmDismiss: (e) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('are you sure?'),
                content: const Text('do you want to remove item from cart?'),
                actions: [
                  TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: const Text('yes')),
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('no'))
                ],
              );
            });
      },
    );
  }
}
