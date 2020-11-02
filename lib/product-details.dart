import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trace_demo/candlestick.dart';
import 'package:trace_demo/models/product-price-info.model.dart';

class ProductDetails extends StatefulWidget {
  final String name;

  ProductDetails(this.name);

  @override
  State<StatefulWidget> createState() => ProductDetailsState(name);
}

class ProductDetailsState extends State {
  final String name;

  ProductDetailsState(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75.0),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          titleSpacing: 2.0,
          title: Text(name),
        )
      ),
      body: Candlestick(),
    );
  }

}