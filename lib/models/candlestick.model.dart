import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trace_demo/models/candlestick-item.model.dart';

import 'candlestick-item.view-model.dart';

class CandlestickModel with ChangeNotifier {
  double _width = 0;
  double _itemWidth = 0;
  double _scaleRatio = 1;
  double _previewScale = 1;
  int _start;
  int _end;
  double _offsetX = 0;
  int _baseViewLength = 50;

  double _minV;

  double get minV => _minV;
  double _maxV;

  double get _baseItemWidth {
    return _width / _baseViewLength;
  }

  double get offsetX => _offsetX;
  List<CandlestickItemViewModel> _items = List.generate(
    5000,
    (index) => CandlestickItemViewModel.fromData(
      CandlestickItem(
          open: Random.secure().nextDouble() * 100,
          close: Random.secure().nextDouble() * 100,
          high: Random.secure().nextDouble() * 100,
          low: Random.secure().nextDouble() * 100,
          time: Random.secure().nextDouble(),
          volume: Random.secure().nextInt(200)),
    ),
  );

  int get start => _start;

  int get viewLength {
    return _end - _start;
  }

  double get realOffsetX {
    return _offsetX * _previewScale;
  }

  List<CandlestickItemViewModel> get items => _items;

  double get itemWidth => _itemWidth;

  int get end => _end;

  init({
    @required double width,
    @required double count,
  }) {
    this._width = width - 50;
    reCalc();
    notifyListeners();
  }

  double _lastOffsetX;
  Offset _zoomFocalPoint;

  Offset get testZoomFocalPoint => _zoomFocalPoint;

  void startScale(Offset focalPoint) {
    _zoomFocalPoint = focalPoint;
    _lastOffsetX = _offsetX;
  }

  void previewScale(double currScale, Offset center) {
    if (currScale == 1) {
      return;
    }
    _previewScale = currScale * _scaleRatio;
    if (_previewScale < 0.1) {
      _previewScale = 0.1;
    } else if (_previewScale > 4) {
      _previewScale = 4;
    }
    var focusXOffset = _lastOffsetX - _zoomFocalPoint.dx / _scaleRatio;
    _offsetX = focusXOffset * (_previewScale - _scaleRatio) / _previewScale +
        center.dx -
        _zoomFocalPoint.dx;
    reCalc();
    notifyListeners();
  }

  void lockScale() {
    _scaleRatio = _previewScale;
  }

  void setItems(List<CandlestickItem> items) {
    this._items =
        items.map((item) => CandlestickItemViewModel.fromData(item)).toList();
    reCalc();
    notifyListeners();
  }

  void horizontalMoving(double currOffset) {
    _offsetX += currOffset / _previewScale;
    // if (_offsetX > 0) {
    //   _offsetX = 0;
    // }
    // if (_offsetX < -_baseItemWidth * _previewScale * items.length + _width) {
    //   _offsetX = -_baseItemWidth * _previewScale * items.length + _width;
    // }
    reCalc();
    notifyListeners();
  }

  int _showDetailsIndex;

  int get showDetailsIndex => _showDetailsIndex;

  void showDetails(Offset position) {
    _showDetailsIndex = (position.dx - realOffsetX + _itemWidth / 2) ~/ _itemWidth;
    if (_showDetailsIndex < 0 || _showDetailsIndex >= _items.length) {
      _showDetailsIndex = null;
    }
    notifyListeners();
  }

  reCalc() {
    _itemWidth = _baseItemWidth * _previewScale;
    _start = (-realOffsetX / _itemWidth).floor();
    _end = _start + (_width / _itemWidth).ceil() + 1;
    if (_start < 0) {
      _start = 0;
    }
    if (_end > _items.length) {
      _end = _items.length;
    }
    _minV = double.infinity;
    _maxV = double.negativeInfinity;
    for (var i = _start; i < _end; ++i) {
      final item = _items[i];
      item.x = realOffsetX + i * _itemWidth;
      final itemMin = min(item.data.high, item.data.low);
      if (_minV > itemMin) {
        _minV = itemMin;
      }
      final itemMax = max(item.data.high, item.data.low);
      if (_maxV < itemMax) {
        _maxV = itemMax;
      }
    }
  }

  double get maxV => _maxV;
}
