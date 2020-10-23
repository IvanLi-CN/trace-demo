import 'package:flutter/material.dart';
import 'package:trace_demo/market-product-item.dart';
import 'package:web_socket_channel/io.dart';
import 'models/product-price-info.model.dart';

class MarketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MarketPageState();
  }
}
class ColumnInfo {
  String prop;
  double width;
  String text;

  ColumnInfo({@required this.prop, @required this.width, @required this.text})
      : assert(prop != null),
        assert(width != null),
        assert(text != null);
}

class _MarketPageState extends State {
  final columnInfoList = [
    ColumnInfo(prop: 'productName', width: .25, text: 'Product'),
    ColumnInfo(prop: 'productName', width: .35, text: 'Product'),
    ColumnInfo(prop: 'productName', width: .28, text: 'Product'),
  ];

  Map<String, ProductPriceInfo> productPriceInfoMap = Map();

  List<String> _productNames = ['EURUSD', 'USDJPY', 'GBPUSD', 'AUDUSD', 'USDCAD', 'USDCHF', 'NZDUSD'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyProductNames = _productNames.where((element) => productPriceInfoMap.containsKey(element)).toList();
    return RefreshIndicator(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Container(
                margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ))),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: columnInfoList
                      .map((info) => new Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width:
                                MediaQuery.of(context).size.width * info.width,
                            child: Text(info.text),
                          ))
                      .toList(),
                ),
              ),
            ]),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => new MarketProductItem(
                  productPriceInfoMap[alreadyProductNames[index]],
                  columnInfoList,
                ),
                childCount: alreadyProductNames.length,
              )),
        ],
      ),
      onRefresh: _reconnectRemote,
    );
  }

  IOWebSocketChannel channel;
  String appCode = 'ivan';

  Future<void> _reconnectRemote() async {
    channel = IOWebSocketChannel.connect('ws://api.hcs55.com:8888/price/$appCode');
    print(0);
    channel.stream.listen((event) {
      final info = ProductPriceInfo.fromBytes(event);
      setState(() {
        productPriceInfoMap.addAll({info.name: info});
      });
    });
    print(2);
    channel.sink.add('sub|${_productNames.join('|')}');
    print(3);
  }
}
