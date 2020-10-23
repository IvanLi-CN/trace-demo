import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProductPriceInfo {
  double bid, ask, last;
  int volume;
  DateTime datetime;
  String name;

  ProductPriceInfo(this.name,
      {@required this.bid,
      @required this.ask,
      @required this.last,
      @required this.volume,
      @required this.datetime});

  ProductPriceInfo.fromBytes(List<int> bytes) {
    final buffer = Int8List.fromList(bytes).buffer;
    final dividerPos = bytes.indexOf(124);
    this.name = AsciiDecoder().convert(bytes, 0, dividerPos);
    final byteData = ByteData.view(buffer, dividerPos + 1);
    this.bid = byteData.getFloat64(0, Endian.little);
    this.ask = byteData.getFloat64(1 * 8, Endian.little);
    this.last = byteData.getFloat64(2 * 8, Endian.little);
    this.volume = byteData.getUint64(3 * 8, Endian.little);
    final datetime_msc = byteData.getInt64(4 * 8, Endian.little);
    this.datetime =
        DateTime.fromMillisecondsSinceEpoch(datetime_msc, isUtc: true);
  }
}
