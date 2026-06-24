import 'package:flutter/material.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';

class DepthSoundingPainter extends CustomPainter {
  final double depthFraction;
  final Color wireColor;
  final InstrumentClassification classification;
  final bool showWeight;

  DepthSoundingPainter({
    required this.depthFraction,
    required this.wireColor,
    required this.classification,
    this.showWeight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final wirePaint = Paint()
      ..color = wireColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final wireTop = size.height * 0.05;
    final wireBottom = wireTop + size.height * (0.25 + depthFraction * 0.65);

    canvas.drawLine(Offset(cx, wireTop), Offset(cx, wireBottom), wirePaint);

    if (!showWeight) return;

    final weightPaint = Paint()
      ..color = wireColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = wireColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    switch (classification) {
      case InstrumentClassification.soundingLead:
        final w = size.width * 0.35;
        final h = size.height * 0.08;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, wireBottom + h / 2),
            width: w,
            height: h,
          ),
          weightPaint,
        );
        break;
      case InstrumentClassification.slipWaterBottle:
      case InstrumentClassification.nansenBottle:
        final w = size.width * 0.28;
        final h = size.height * 0.14;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, wireBottom + h / 2),
              width: w,
              height: h,
            ),
            const Radius.circular(2),
          ),
          strokePaint,
        );
        break;
      case InstrumentClassification.driftIndicator:
        canvas.drawCircle(Offset(cx, wireBottom + 6), size.width * 0.14, strokePaint);
        canvas.drawLine(
          Offset(cx - size.width * 0.14, wireBottom + 6),
          Offset(cx + size.width * 0.14, wireBottom + 6),
          strokePaint,
        );
        break;
      case InstrumentClassification.reversingThermometer:
        final gap = size.width * 0.08;
        for (final dx in [-gap, gap]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(cx + dx, wireBottom + 8),
                width: size.width * 0.12,
                height: size.height * 0.16,
              ),
              const Radius.circular(2),
            ),
            strokePaint,
          );
        }
        break;
      default:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(cx, wireBottom + 6),
            width: size.width * 0.3,
            height: size.height * 0.1,
          ),
          strokePaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant DepthSoundingPainter old) =>
      old.depthFraction != depthFraction ||
      old.wireColor != wireColor ||
      old.classification != classification;
}
