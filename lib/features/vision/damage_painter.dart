import 'package:flutter/material.dart';

class DetectionResult {
  final Rect rect;
  final String label;
  final double score;

  DetectionResult({
    required this.rect,
    required this.label,
    required this.score,
  });
}

class DamagePainter extends CustomPainter {
  final List<DetectionResult> results;

  DamagePainter({this.results = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    if (results.isEmpty) {
      _drawDefaultBox(canvas, size, boxPaint);
      return;
    }

    for (var res in results) {
      _drawDetection(canvas, size, res, boxPaint, fillPaint);
    }
  }

  Color getColor(String label) {
    if (label.contains("D40")) return Colors.red;
    if (label.contains("D00")) return Colors.yellow;
    return Colors.orange;
  }

  String getSeverity(double score) {
    if (score > 0.85) return "Parah";
    if (score > 0.7) return "Sedang";
    return "Ringan";
  }

  void _drawDefaultBox(Canvas canvas, Size size, Paint paint) {
    double boxSize = size.width * 0.5;
    double left = (size.width - boxSize) / 2;
    double top = (size.height - boxSize) / 2;

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);
    canvas.drawRect(rect, paint);

    _drawLabel(
      canvas,
      text: "Scanning for Road Damage...",
      x: left,
      y: top - 25,
      color: Colors.redAccent,
    );
  }

  void _drawDetection(
    Canvas canvas,
    Size size,
    DetectionResult res,
    Paint boxPaint,
    Paint fillPaint,
  ) {
    double left = res.rect.left * size.width;
    double top = res.rect.top * size.height;
    double width = res.rect.width * size.width;
    double height = res.rect.height * size.height;

    final rect = Rect.fromLTWH(left, top, width, height);

    boxPaint.color = getColor(res.label);

    canvas.drawRect(rect, boxPaint);

    String severity = getSeverity(res.score);

    String text =
        "${res.label} - $severity (${(res.score * 100).toStringAsFixed(0)}%)";

    _drawLabel(
      canvas,
      text: text,
      x: left,
      y: top - 25,
      color: getColor(res.label),
    );
  }

  void _drawLabel(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required Color color,
  }) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: color,
      shadows: [
        Shadow(blurRadius: 4, color: Colors.black, offset: Offset(1, 1)),
      ],
    );

    final textSpan = TextSpan(text: " $text ", style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    double safeY = y < 0 ? y.abs() + 5 : y;

    textPainter.paint(canvas, Offset(x, safeY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
