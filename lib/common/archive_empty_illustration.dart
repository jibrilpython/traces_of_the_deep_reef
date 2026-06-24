import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

/// Illustration for an empty specimen archive — isometric sounding column
/// with a gently bobbing lead weight and placeholder orbit ring.
class ArchiveEmptyIllustration extends StatefulWidget {
  const ArchiveEmptyIllustration({super.key});

  @override
  State<ArchiveEmptyIllustration> createState() =>
      _ArchiveEmptyIllustrationState();
}

class _ArchiveEmptyIllustrationState extends State<ArchiveEmptyIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _bob = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148.w,
      height: 148.w,
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, _) {
          return CustomPaint(
            painter: _ArchiveEmptyPainter(bob: _bob.value),
          );
        },
      ),
    );
  }
}

class _ArchiveEmptyPainter extends CustomPainter {
  final double bob;

  _ArchiveEmptyPainter({required this.bob});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft halo
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.46,
      Paint()
        ..shader = RadialGradient(
          colors: [
            kAccentSurface,
            kAccentSurface.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 68)),
    );

    // Outer case
    final caseR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.82, height: size.height * 0.88),
      Radius.circular(18.r),
    );
    canvas.drawRRect(caseR, Paint()..color = kPanelBg);
    canvas.drawRRect(
      caseR,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Isometric column — back face
    final colTop = cy - size.height * 0.28;
    final colBot = cy + size.height * 0.26;
    final topW = size.width * 0.18;
    final botW = size.width * 0.34;
    final depthSkew = size.width * 0.06;

    final backPath = Path()
      ..moveTo(cx - topW - depthSkew, colTop)
      ..lineTo(cx + topW - depthSkew, colTop)
      ..lineTo(cx + botW - depthSkew, colBot)
      ..lineTo(cx - botW - depthSkew, colBot)
      ..close();
    canvas.drawPath(
      backPath,
      Paint()..color = kAccent.withValues(alpha: 0.08),
    );

    // Front face
    final frontPath = Path()
      ..moveTo(cx - topW, colTop)
      ..lineTo(cx + topW, colTop)
      ..lineTo(cx + botW, colBot)
      ..lineTo(cx - botW, colBot)
      ..close();
    canvas.drawPath(
      frontPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kAccent.withValues(alpha: 0.14),
            kAccent.withValues(alpha: 0.32),
          ],
        ).createShader(Rect.fromLTRB(cx - botW, colTop, cx + botW, colBot)),
    );
    canvas.drawPath(
      frontPath,
      Paint()
        ..color = kAccent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Side edge
    canvas.drawLine(
      Offset(cx + topW, colTop),
      Offset(cx + topW - depthSkew, colTop),
      Paint()
        ..color = kAccent.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx + botW, colBot),
      Offset(cx + botW - depthSkew, colBot),
      Paint()
        ..color = kAccent.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );

    // Depth shelves
    final shelfPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final t = i / 4;
      final y = colTop + (colBot - colTop) * t;
      final halfW = topW + (botW - topW) * t;
      canvas.drawLine(
        Offset(cx - halfW + 4, y),
        Offset(cx + halfW - 4, y),
        shelfPaint,
      );
    }

    // Bobbing wire + weight
    final wireTop = colTop + 8;
    final wireLen = (colBot - colTop) * (0.42 + bob * 0.04);
    final wireEnd = wireTop + wireLen;
    final sway = math.sin(bob * math.pi) * 2.5;

    canvas.drawLine(
      Offset(cx + sway * 0.3, wireTop),
      Offset(cx + sway, wireEnd),
      Paint()
        ..color = kSecondaryAccent.withValues(alpha: 0.75)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // Lead weight (3D-ish ellipse)
    final weightY = wireEnd + 5 + bob * 3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + sway, weightY + 3),
        width: 22,
        height: 7,
      ),
      Paint()..color = kSecondaryAccent.withValues(alpha: 0.2),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + sway, weightY),
        width: 20,
        height: 9,
      ),
      Paint()..color = kSecondaryAccent,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + sway - 2, weightY - 1),
        width: 10,
        height: 4,
      ),
      Paint()..color = kSecondaryAccent.withValues(alpha: 0.35),
    );

    // Placeholder orbit ring (dashed)
    final ringR = size.width * 0.22;
    final ringCenter = Offset(cx, cy + size.height * 0.08);
    final ringPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const dash = 5.0;
    const gap = 4.0;
    var dist = 0.0;
    Offset? last;
    for (var a = 0.0; a <= math.pi * 2; a += 0.08) {
      final p = ringCenter +
          Offset(math.cos(a) * ringR, math.sin(a) * ringR * 0.42);
      if (last != null) {
        final prev = last;
        final seg = (p - prev).distance;
        if (dist + seg > dash) {
          canvas.drawLine(prev, p, ringPaint);
          dist = 0;
          last = p;
          dist += gap;
          continue;
        }
        dist += seg;
      }
      last = p;
    }

    // Small plus badge — "add here"
    final badgeCenter = Offset(cx + ringR * 0.55, cy - size.height * 0.1);
    canvas.drawCircle(
      badgeCenter,
      11,
      Paint()..color = kAccent,
    );
    final plus = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      badgeCenter + const Offset(-5, 0),
      badgeCenter + const Offset(5, 0),
      plus,
    );
    canvas.drawLine(
      badgeCenter + const Offset(0, -5),
      badgeCenter + const Offset(0, 5),
      plus,
    );

    // Surface ripple lines at top
    final ripple = Paint()
      ..color = kAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final ry = colTop - 10 - i * 5;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, ry), width: 40 + i * 8, height: 8),
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        ripple,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArchiveEmptyPainter old) => old.bob != bob;
}
