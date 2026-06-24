import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/common/depth_sounding_painter.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/providers/project_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});
  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen>
    with SingleTickerProviderStateMixin {
  String? _firstId;
  String? _secondId;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  OceanographicToolModel? _find(String? id, List<OceanographicToolModel> list) {
    if (id == null) return null;
    for (final e in list) {
      if (e.id == id) return e;
    }
    return null;
  }

  void _pickSpecimen(bool isFirst) {
    final entries = ref.read(projectProvider).entries;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: kOutline),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  isFirst ? 'Choose first specimen' : 'Choose second specimen',
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryText,
                  ),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No specimens to compare',
                          style: GoogleFonts.ibmPlexSans(
                            color: kSecondaryText,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => SizedBox(height: 8.h),
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          final blocked = (isFirst && _secondId == e.id) ||
                              (!isFirst && _firstId == e.id);
                          return ListTile(
                            enabled: !blocked,
                            onTap: blocked
                                ? null
                                : () {
                                    setState(() {
                                      if (isFirst) {
                                        _firstId = e.id;
                                      } else {
                                        _secondId = e.id;
                                      }
                                    });
                                    Navigator.pop(ctx);
                                  },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: kOutline),
                            ),
                            tileColor: kBackground,
                            leading: CircleAvatar(
                              backgroundColor: kAccentSurface,
                              child: Icon(
                                Icons.anchor_outlined,
                                color: kAccent,
                                size: 18.sp,
                              ),
                            ),
                            title: Text(
                              e.artisanHallmark.isNotEmpty
                                  ? e.artisanHallmark
                                  : 'Unknown maker',
                              style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            subtitle: Text(
                              e.instrumentClassification.label,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12.sp,
                                color: kSecondaryText,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 12.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final first = _find(_firstId, entries);
    final second = _find(_secondId, entries);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: kBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Compare',
              style: GoogleFonts.libreBaskerville(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: kPrimaryText,
              ),
            ),
            actions: [
              if (first != null || second != null)
                TextButton(
                  onPressed: () => setState(() {
                    _firstId = null;
                    _secondId = null;
                  }),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.ibmPlexSans(
                      color: kAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select two instruments to compare depth ratings, materials, and expedition provenance side by side.',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14.sp,
                      color: kSecondaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: _SpecimenSlot(
                          label: 'First',
                          entry: first,
                          accent: kAccent,
                          onTap: () => _pickSpecimen(true),
                          onClear: first != null
                              ? () => setState(() => _firstId = null)
                              : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'vs',
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 13.sp,
                            color: kSecondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _SpecimenSlot(
                          label: 'Second',
                          entry: second,
                          accent: kSecondaryAccent,
                          onTap: () => _pickSpecimen(false),
                          onClear: second != null
                              ? () => setState(() => _secondId = null)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (first != null && second != null) ...[
                    SizedBox(height: 28.h),
                    _ComparisonTable(first: first, second: second),
                  ],
                  SizedBox(height: 24.h),
                  _DepthSoundingFootnote(
                    first: first,
                    second: second,
                    pulse: _pulse,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 96.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepthSoundingFootnote extends StatelessWidget {
  final OceanographicToolModel? first;
  final OceanographicToolModel? second;
  final Animation<double> pulse;

  const _DepthSoundingFootnote({
    required this.first,
    required this.second,
    required this.pulse,
  });

  String _caption() {
    if (first == null && second == null) {
      return 'Select two specimens to lower their sounding lines into the column and read how their rated depths diverge.';
    }
    if (first == null || second == null) {
      return 'One line is set. Choose the second instrument to complete the twin sounding.';
    }
    if (first!.oceanDepthZone == second!.oceanDepthZone) {
      return 'Both instruments share the ${first!.oceanDepthZone.label.split(' ').first.toLowerCase()} zone — compare materials and expedition provenance above.';
    }
    final a = getDepthFraction(first!.oceanDepthZone);
    final b = getDepthFraction(second!.oceanDepthZone);
    final delta = ((b - a).abs() * 4000).round();
    return 'Rated depths diverge by roughly $delta m across the water column — deeper zones demand heavier ballast and tougher metallurgy.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves_rounded, size: 18.sp, color: kAccent),
              SizedBox(width: 8.w),
              Text(
                'Twin sounding column',
                style: GoogleFonts.libreBaskerville(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) {
              return SizedBox(
                height: 148.h,
                child: Row(
                  children: [
                    Expanded(
                      child: _SoundingWire(
                        label: 'First',
                        entry: first,
                        accent: kAccent,
                        idleDepth: 0.35 + pulse.value * 0.06,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: CustomPaint(
                        painter: _DepthColumnPainter(
                          leftDepth: first != null
                              ? getDepthFraction(first!.oceanDepthZone)
                              : 0.35 + pulse.value * 0.06,
                          rightDepth: second != null
                              ? getDepthFraction(second!.oceanDepthZone)
                              : 0.55 - pulse.value * 0.06,
                          leftColor: first != null
                              ? getDepthZoneColor(first!.oceanDepthZone)
                              : kAccent.withValues(alpha: 0.35),
                          rightColor: second != null
                              ? getDepthZoneColor(second!.oceanDepthZone)
                              : kSecondaryAccent.withValues(alpha: 0.35),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _SoundingWire(
                        label: 'Second',
                        entry: second,
                        accent: kSecondaryAccent,
                        idleDepth: 0.55 - pulse.value * 0.06,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 14.h),
          Text(
            _caption(),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12.sp,
              color: kSecondaryText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundingWire extends StatelessWidget {
  final String label;
  final OceanographicToolModel? entry;
  final Color accent;
  final double idleDepth;

  const _SoundingWire({
    required this.label,
    required this.entry,
    required this.accent,
    required this.idleDepth,
  });

  @override
  Widget build(BuildContext context) {
    final depth = entry != null
        ? getDepthFraction(entry!.oceanDepthZone)
        : idleDepth;
    final color =
        entry != null ? getDepthZoneColor(entry!.oceanDepthZone) : accent;
    final classification = entry?.instrumentClassification ??
        InstrumentClassification.soundingLead;

    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 9.sp,
            color: kSecondaryText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        Expanded(
          child: CustomPaint(
            painter: DepthSoundingPainter(
              depthFraction: depth,
              wireColor: color,
              classification: classification,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (entry != null) ...[
          SizedBox(height: 6.h),
          Text(
            entry!.oceanDepthZone.label.split(' ').first,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _DepthColumnPainter extends CustomPainter {
  final double leftDepth;
  final double rightDepth;
  final Color leftColor;
  final Color rightColor;

  _DepthColumnPainter({
    required this.leftDepth,
    required this.rightDepth,
    required this.leftColor,
    required this.rightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final columnRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, 8, size.width * 0.44, size.height - 16),
      const Radius.circular(10),
    );

    final columnPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kAccentSurface,
          kAccent.withValues(alpha: 0.15),
          const Color(0xFF0F3D4C).withValues(alpha: 0.35),
        ],
      ).createShader(columnRect.outerRect);
    canvas.drawRRect(columnRect, columnPaint);

    final border = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(columnRect, border);

    const ticks = ['0 m', '200', '1k', '4k+'];
    for (var i = 0; i < ticks.length; i++) {
      final y = columnRect.top + (columnRect.height / 3) * i;
      final tickPaint = Paint()
        ..color = kSecondaryText.withValues(alpha: 0.35)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(columnRect.left - 6, y),
        Offset(columnRect.right + 6, y),
        tickPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: ticks[i],
          style: const TextStyle(
            color: Color(0xFF5A6B7A),
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(columnRect.right + 10, y - tp.height / 2));
    }

    void drawMarker(double depthFrac, Color color, bool isLeft) {
      final y = columnRect.top + columnRect.height * depthFrac.clamp(0.1, 0.92);
      final x = isLeft ? columnRect.left - 4 : columnRect.right + 4;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x, y),
        Offset(isLeft ? columnRect.left + 8 : columnRect.right - 8, y),
        paint,
      );
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
    }

    drawMarker(leftDepth, leftColor, true);
    drawMarker(rightDepth, rightColor, false);

    final arcPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final midY = columnRect.top +
        columnRect.height * ((leftDepth + rightDepth) / 2).clamp(0.15, 0.85);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(columnRect.center.dx, midY),
        width: columnRect.width * 0.9,
        height: (rightDepth - leftDepth).abs() * columnRect.height * 0.8 + 12,
      ),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DepthColumnPainter old) =>
      old.leftDepth != leftDepth ||
      old.rightDepth != rightDepth ||
      old.leftColor != leftColor ||
      old.rightColor != rightColor;
}

class _SpecimenSlot extends ConsumerWidget {
  final String label;
  final OceanographicToolModel? entry;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _SpecimenSlot({
    required this.label,
    required this.entry,
    required this.accent,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = entry != null
        ? ref.watch(imageProvider).getImagePath(entry!.photoPath)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: entry != null ? accent : kOutline,
            width: entry != null ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: entry == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: kSecondaryText, size: 28.sp),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13.sp,
                      color: kSecondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (imagePath != null && File(imagePath).existsSync())
                    Image.file(File(imagePath), fit: BoxFit.cover)
                  else
                    ColoredBox(
                      color: kAccentSurface.withValues(alpha: 0.5),
                      child: Icon(Icons.anchor_outlined,
                          color: accent, size: 32.sp),
                    ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      color: accent,
                      child: Text(
                        label,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        entry!.artisanHallmark.isNotEmpty
                            ? entry!.artisanHallmark
                            : 'Unknown maker',
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    Positioned(
                      top: 32.h,
                      right: 6.w,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: Colors.white, size: 18.sp),
                        onPressed: onClear,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final OceanographicToolModel first;
  final OceanographicToolModel second;

  const _ComparisonTable({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _Row('Type', first.instrumentClassification.label,
          second.instrumentClassification.label),
      _Row('Depth zone', first.oceanDepthZone.label, second.oceanDepthZone.label),
      _Row('Bounds', first.soundingPressureBounds, second.soundingPressureBounds),
      _Row('Valving', first.valvingSealingMechanics.label,
          second.valvingSealingMechanics.label),
      _Row('Metallurgy', first.compositionMetallurgy.label,
          second.compositionMetallurgy.label),
      _Row('Era', first.era, second.era),
      _Row('Calibration site', first.calibrationSite, second.calibrationSite),
      _Row(
        'Condition',
        first.preservationSoundness.label.split(' — ').first,
        second.preservationSoundness.label.split(' — ').first,
      ),
      _Row('Expedition', first.expeditionGroundZero, second.expeditionGroundZero),
    ];

    final matches =
        rows.where((r) => r.matches).length;
    final pct = (matches / rows.length * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Similarity',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13.sp,
                        color: kSecondaryText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 6.h,
                        backgroundColor: kOutline,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                '$pct%',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: kAccent,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...rows.map((row) => _DiffRow(row: row)),
      ],
    );
  }
}

class _Row {
  final String label;
  final String a;
  final String b;
  _Row(this.label, this.a, this.b);
  bool get matches =>
      a.trim().toLowerCase() == b.trim().toLowerCase() &&
      a.isNotEmpty &&
      b.isNotEmpty;
}

class _DiffRow extends StatelessWidget {
  final _Row row;
  const _DiffRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final a = row.a.isEmpty ? '—' : row.a;
    final b = row.b.isEmpty ? '—' : row.b;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: row.matches ? kOutline : kAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                row.matches
                    ? Icons.check_circle_outline
                    : Icons.info_outline_rounded,
                size: 14.sp,
                color: row.matches ? const Color(0xFF059669) : kAccent,
              ),
              SizedBox(width: 6.w),
              Text(
                row.label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: kSecondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  a,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13.sp,
                    color: row.matches ? kPrimaryText : kAccent,
                    fontWeight:
                        row.matches ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text('·',
                    style: TextStyle(color: kOutline, fontSize: 16.sp)),
              ),
              Expanded(
                child: Text(
                  b,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13.sp,
                    color: row.matches ? kPrimaryText : kSecondaryAccent,
                    fontWeight:
                        row.matches ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
