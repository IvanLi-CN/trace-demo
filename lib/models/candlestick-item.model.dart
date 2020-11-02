import 'package:flutter/material.dart';

class CandlestickItem {
  final double open;
  final double close;
  final double high;
  final double low;
  final double time;
  final int volume;

  CandlestickItem({
    @required this.open,
    @required this.close,
    @required this.high,
    @required this.low,
    @required this.time,
    @required this.volume,
  });

  CandlestickItem.fromJson(Map<String, dynamic> map)
      : open = double.parse(map['open']),
        close = double.parse(map['close']),
        high = double.parse(map['high']),
        low = double.parse(map['low']),
        time = double.parse(map['time']),
        volume = 0; //int.parse(map['volume'], 10);
}
