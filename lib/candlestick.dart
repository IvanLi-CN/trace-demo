import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trace_demo/models/candlestick-item.model.dart';
import 'package:trace_demo/models/candlestick.model.dart';

class Candlestick extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CandlestickState();
  }
}

class _CandlestickState extends State<Candlestick> {
  final CandlestickModel model = CandlestickModel();

  @override
  void initState() {
    fetchKLineData();
    super.initState();
  }

  Future<void> fetchKLineData() async {
    // final response = await Dio().get('https://apiv2.bitz.com/Market/kline?symbol=eth_btc&resolution=5min');
    final data = await rootBundle.loadString('lib/models/data.json');
    final bars = JsonDecoder().convert(data)['data']['bars'] as List<dynamic>;
    model.setItems(bars.map((bar) => CandlestickItem.fromJson(bar)).toList());
  }

  @override
  Widget build(BuildContext context) {
    model.init(width: MediaQuery.of(context).size.width, count: 20);
    return ChangeNotifierProvider(
      create: (_) => model,
      child: GestureDetector(
        child: Container(
            color: Theme.of(context).backgroundColor,
            child: Consumer<CandlestickModel>(
              builder: (_, model, __) => CustomPaint(
                painter: _Painter(model: model),
                child: Container(
                  child: Center(
                    child: Consumer<CandlestickModel>(
                      builder: (_, model, __) =>
                          Text(model.showDetailsIndex.toString()),
                    ),
                  ),
                ),
              ),
            )),
        onScaleStart: (details) {
          model.startScale(details.localFocalPoint);
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          model.previewScale(details.scale, details.localFocalPoint);
        },
        onScaleEnd: (ScaleEndDetails details) {
          model.lockScale();
        },
        onHorizontalDragUpdate: (details) {
          model.horizontalMoving(details.delta.dx);
        },
        onLongPressStart: (LongPressStartDetails details) {
          model.showDetails(details.localPosition);
        },
        onLongPressMoveUpdate: (details) {
          model.showDetails(details.localPosition);
        },
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final CandlestickModel model;

  _Painter({
    this.model,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2.0;
    if (model.testZoomFocalPoint != null) {
      canvas.drawCircle(
          model.testZoomFocalPoint, 5.0, paint..color = Colors.green);
    }
    _paintGrid(canvas, size);
    _paintYAxis(canvas, size);
    _paintCandles(canvas, size);
    _paintDetails(canvas, size);
  }

  void _paintDetails(Canvas canvas, Size size) {
    if (model.showDetailsIndex == null) {
      return;
    }
    final paint = Paint()
      ..color = Color.fromARGB(20, 0, 200, 255)
      ..style = PaintingStyle.fill;

    final item = model.items[model.showDetailsIndex];

    canvas.drawRect(
        Rect.fromLTRB(
          item.x - model.itemWidth / 2,
          0,
          item.x + model.itemWidth / 2,
          size.height,
        ),
        paint);

    final highPainter = TextPainter(
      text: TextSpan(
        text: item.data.high.toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    )..layout(maxWidth: 96, minWidth: 96);
    final dpPerValue = size.height / (model.maxV - model.minV);
    final top = dpPerValue * (model.maxV - item.data.high) - highPainter.height / 2;
    final bottom = dpPerValue * (model.maxV - item.data.high) + highPainter.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(size.width - 100, top - 10, size.width, bottom + 10), paint,
    );
    highPainter.paint(
      canvas,
      Offset(size.width - 100, top),
    );
  }

  void _paintYAxis(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final max = model.maxV;
    final min = model.minV;
    final diff = max - min;
    const expectReferenceLineGap = 50;
    final referenceLineCount = (size.height / expectReferenceLineGap).ceil();
    final referenceLineGap = size.height / referenceLineCount;
    final valuePreGap = diff / referenceLineCount;
    for (int i = 0; i <= referenceLineCount; ++i) {
      final y = i * referenceLineGap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      final span = TextSpan(
        text: ((max - i * valuePreGap)).toStringAsFixed(5),
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      )..layout(maxWidth: 46, minWidth: 46);
      painter.paint(canvas, Offset(size.width - 50, y - painter.height / 2));
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paint1 = Paint()
      ..color = Colors.green[100]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paint2 = Paint()
      ..color = Colors.grey[100]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paint3 = Paint()
      ..color = Colors.blue[100]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paints = [paint1, paint2, paint3];
    for (int i = model.start; i < model.end; ++i) {
      final x = model.items[i].x;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paints[i % 3]);

      TextPainter textP = TextPainter(
        text: TextSpan(
            text: i.toStringAsFixed(0), style: TextStyle(color: Colors.black)),
        textDirection: TextDirection.ltr,
      );
      textP.layout();
      textP.paint(canvas, Offset(x, size.height - textP.height));
    }
  }

  void _paintCandles(Canvas canvas, Size size) {
    final riseColor = Colors.green[600];
    final fallColor = Colors.red[600];
    final riseStrokePaint = Paint()
      ..color = riseColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final riseFillPaint = Paint()
      ..color = riseColor
      ..style = PaintingStyle.fill;
    final fallStrokePaint = Paint()
      ..color = fallColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fallFillPaint = Paint()
      ..color = fallColor
      ..style = PaintingStyle.fill;

    final unitY = size.height / (model.maxV - model.minV);
    for (var item in model.items.sublist(model.start, model.end)) {
      final data = item.data;
      canvas.drawRect(
          Rect.fromLTRB(
            item.x - model.itemWidth / 2,
            (model.maxV - data.open) * unitY,
            item.x + model.itemWidth / 2,
            (model.maxV - data.close) * unitY,
          ),
          data.open > data.close ? riseFillPaint : fallFillPaint);
      canvas.drawLine(
          Offset(item.x, (model.maxV - data.high) * unitY),
          Offset(item.x, (model.maxV - data.low) * unitY),
          data.open > data.close ? riseStrokePaint : fallStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
