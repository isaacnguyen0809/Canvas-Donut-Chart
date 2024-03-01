import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final List<DataItem> dataSet = [
  DataItem(value: 0.2, label: "Comedy", color: Colors.red),
  DataItem(value: 0.25, label: "Action", color: Colors.brown),
  DataItem(value: 0.3, label: "Romance", color: Colors.green),
  DataItem(value: 0.05, label: "Drama", color: Colors.lime),
  DataItem(value: 0.2, label: "SciFi", color: Colors.pink)
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.teal,
          body: DonutChartWidget(dataSet),
        ));
  }
}

class DataItem {
  final double value;
  final String label;
  final Color color;

  DataItem({required this.value, required this.label, required this.color});
}

class DonutChartWidget extends StatefulWidget {
  final List<DataItem> dataSet;

  const DonutChartWidget(this.dataSet, {Key? key}) : super(key: key);

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  late Timer timer;
  double fullAngle = 0.0;
  double secondsToComplete = 5.0;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        fullAngle += 360.0 / (secondsToComplete * 1000 ~/ 60);
        if (fullAngle >= 360.0) {
          fullAngle = 360.0;
          timer.cancel();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DonutChartPainter(widget.dataSet, fullAngle),
      child: Container(),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<DataItem> dataSet;
  final double fullAngle;

  DonutChartPainter(this.dataSet, this.fullAngle);

  static const labelStyle = TextStyle(color: Colors.black, fontSize: 11.0);
  final midPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final borderPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  static const textBigStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25.0);

  @override
  void paint(Canvas canvas, Size size) {
    final linePath = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final c = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.9;
    final rect = Rect.fromCenter(center: c, width: radius, height: radius);

    var startAngle = 0.0;
    for (var di in dataSet) {
      final sweepAngle = di.value * fullAngle / 180 * pi;
      drawSectors(di, canvas, rect, startAngle, sweepAngle);
      startAngle += sweepAngle;
    }

    startAngle = 0.0;
    for (var di in dataSet) {
      final sweepAngle = di.value * fullAngle / 180 * pi;
      drawLines(radius, startAngle, c, canvas, linePath);
      startAngle += sweepAngle;
    }

    startAngle = 0.0;
    for (var di in dataSet) {
      final sweepAngle = di.value * fullAngle / 180 * pi;
      drawLabels(canvas, c, radius, startAngle, sweepAngle, di.label);
      startAngle += sweepAngle;
    }

    canvas.drawCircle(c, radius * 0.3, midPaint);
    canvas.drawCircle(c, radius/2, borderPaint);
    drawTextCentered(canvas, c, "Favourite Movie Genres", textBigStyle, radius * 0.5, (Size sz) {});
  }

  TextPainter measureText(
      String string, TextStyle textStyle, double maxWidth, TextAlign textAlign) {
    final span = TextSpan(text: string, style: textStyle);
    final tp = TextPainter(text: span, textAlign: textAlign, textDirection: TextDirection.ltr);
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    return tp;
  }

  Size drawTextCentered(Canvas canvas, Offset position, String text, TextStyle textStyle,
      double maxWidth, Function(Size size) bgCb) {
    final textPainter = measureText(text, textStyle, maxWidth, TextAlign.center);
    final pos = position + Offset(-textPainter.width / 2.0, -textPainter.height / 2.0);
    bgCb(textPainter.size);
    textPainter.paint(canvas, pos);
    return textPainter.size;
  }

  void drawLines(double radius, double startAngle, Offset c, Canvas canvas, Paint linePath) {
    final lineLength = radius / 2;
    final dx = lineLength * cos(startAngle);
    final dy = lineLength * sin(startAngle);
    final p2 = c + Offset(dx, dy);
    canvas.drawLine(c, p2, linePath);
  }

  void drawSectors(DataItem di, Canvas canvas, Rect rect, double startAngle, double sweepAngle) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = di.color;
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  void drawLabels(
      Canvas canvas, Offset c, double radius, double startAngle, double sweepAngle, String label) {
    final r = radius * 0.4;
    final dx = r * cos(startAngle + sweepAngle / 2.0);
    final dy = r * sin(startAngle + sweepAngle / 2.0);
    final position = c + Offset(dx, dy);
    drawTextCentered(canvas, position, label, labelStyle, 100.0, (Size size) {
      final rect =
          Rect.fromCenter(center: position, width: size.width + 5, height: size.height + 5);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
      canvas.drawRRect(rrect, midPaint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
