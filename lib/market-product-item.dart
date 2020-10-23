import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'product-details.dart';
import 'market.dart';
import 'models/product-price-info.model.dart';

class MarketProductItem extends StatelessWidget {
  ProductPriceInfo info;
  List<ColumnInfo> columnInfoList;

  MarketProductItem(this.info, this.columnInfoList);

  @override
  Widget build(BuildContext context) => InkWell(
        child: Container(
            decoration: BoxDecoration(),
            padding: const EdgeInsets.all(8.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Container(
                    width: MediaQuery.of(context).size.width *
                        columnInfoList[0].width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(info.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(fontWeightDelta: 2, fontSizeDelta: 1)),
                        Text(info.datetime.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .apply(fontWeightDelta: -1, fontSizeDelta: -1)),
                      ],
                    )),
                new Container(
                    width: MediaQuery.of(context).size.width *
                        columnInfoList[1].width,
                    child: Column(
                      children: [
                        Text(info.ask.toString()),
                        Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                        Text(info.bid.toString()),
                      ],
                    )),
                new Container(
                    width: MediaQuery.of(context).size.width *
                        columnInfoList[2].width,
                    child: Column(
                      children: [
                        Text(info.volume.toString()),
                        Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                        Text(info.last.toString()),
                      ],
                    )),
              ],
            )),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductDetails(info.name),
          ));
        },
      );
}
