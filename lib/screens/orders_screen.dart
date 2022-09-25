import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/widgets/app_drawer_widget.dart';
import 'package:shop_app/widgets/order_item_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);


  static const routeName = '/order';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();


}


class _OrdersScreenState extends State<OrdersScreen> {

  var _isLoading = false;


  @override
  void initState() {

    Future.delayed(Duration.zero).then((_) async {
      setState((){
        _isLoading = true;
      });
      await Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
      setState((){
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('ORDER SCREEN BUILT');
    final orders = Provider.of<OrderProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('your orders'),
        ),
        drawer: const AppDrawerWidget(),
        body: _isLoading ? Center(child: JumpingDotsProgressIndicator(
          fontSize: 40,
        )):ListView.builder(
          itemCount: orders.orderItemsCount(),
          itemBuilder: (context, index) =>
              OrderItemWidget(orderItem: orders.orderItems[index]),
        ));
  }


}
