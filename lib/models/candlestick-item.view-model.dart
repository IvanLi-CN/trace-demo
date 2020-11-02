import 'package:trace_demo/models/candlestick-item.model.dart';

class CandlestickItemViewModel {
  CandlestickItem data;
  double x;
  CandlestickItemViewModel.fromData(CandlestickItem data): this.data = data;
}