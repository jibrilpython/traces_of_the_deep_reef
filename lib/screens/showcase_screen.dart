import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/common/depth_sounding_painter.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/providers/project_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

const _abyss = Color(0xFF060D14);
const _deep = Color(0xFF0B1520);
const _mid = Color(0xFF0F2A38);
const _shallow = Color(0xFF1A3A4A);
const _fog = Color(0xFFEFF2F5);

class _SceneNode {
  final OceanographicToolModel model;
  final int index;
  final double shelfY;
  final double orbitAngle;
  final double orbitRadius;
  double bob = 0;
  bool behindColumn = false;

  _SceneNode({
    required this.model,
    required this.index,
    required this.shelfY,
    required this.orbitAngle,
    required this.orbitRadius,
  });
}

class _Projected {
  final Offset position;
  final double scale;
  final double depth;
  final double cameraRz;

  const _Projected({
    required this.position,
    required this.scale,
    required this.depth,
    required this.cameraRz,
  });

  bool get isBehindColumn => cameraRz > 0;
}

class _SceneMath {
  static const focal = 520.0;
  static const depthOffset = 220.0;

  static _Projected project({
    required double x,
    required double y,
    required double z,
    required double cameraYaw,
    required double cameraPitch,
    required double drift,
    required Size size,
  }) {
    final cosY = math.cos(cameraYaw);
    final sinY = math.sin(cameraYaw);
    final rx = x * cosY - z * sinY;
    final rz = x * sinY + z * cosY;

    final cosP = math.cos(cameraPitch);
    final sinP = math.sin(cameraPitch);
    final ry = y * cosP - rz * sinP;
    final fz = y * sinP + rz * cosP + depthOffset;

    final perspective = focal / (focal + fz);
    return _Projected(
      position: Offset(
        size.width * 0.5 + rx * perspective,
        size.height * 0.46 + ry * perspective + drift * size.height,
      ),
      scale: perspective.clamp(0.35, 1.15),
      depth: fz,
      cameraRz: rz,
    );
  }
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;
  double _cameraYaw = 0.55;
  double _cameraPitch = 0.38;
  double _targetYaw = 0.55;
  double _targetPitch = 0.38;
  double _drift = 0;
  int? _selectedIndex;
  List<_SceneNode> _nodes = [];
  int _lastBuildHash = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _time += 1 / 60;
    if (_selectedIndex == null) {
      _targetYaw += math.sin(_time * 0.22) * 0.0009;
      _drift = math.sin(_time * 0.35) * 0.015;
    }
    _cameraYaw += (_targetYaw - _cameraYaw) * 0.06;
    _cameraPitch += (_targetPitch - _cameraPitch) * 0.06;

    for (final n in _nodes) {
      n.bob = math.sin(_time * 1.4 + n.orbitAngle * 2) * 6;
      _updateBehindState(n);
    }
    if (mounted) setState(() {});
  }

  void _rebuildNodes(List<OceanographicToolModel> entries) {
    final hash = Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
    );
    if (_lastBuildHash == hash) return;
    _lastBuildHash = hash;

    final rand = math.Random(42);
    final zoneBuckets = <OceanDepthZone, List<OceanographicToolModel>>{};
    for (final e in entries) {
      zoneBuckets.putIfAbsent(e.oceanDepthZone, () => []).add(e);
    }

    _nodes = [];
    for (final entry in entries) {
      final zone = entry.oceanDepthZone;
      final bucket = zoneBuckets[zone]!;
      final count = bucket.length;
      final posInBucket = bucket.indexOf(entry);
      final zoneOffset = zone.index * math.pi * 0.22;

      final double angle;
      final double orbitRadius;
      if (count == 1) {
        angle = zoneOffset + rand.nextDouble() * 0.5;
        orbitRadius = 118;
      } else {
        angle = ((posInBucket + 0.5) / count) * math.pi * 2 + zoneOffset;
        final radiusStagger = (posInBucket - (count - 1) / 2) * 26;
        final crowdBoost = math.max(0, count - 3) * 14.0;
        orbitRadius = 118 + crowdBoost + radiusStagger;
      }

      _nodes.add(_SceneNode(
        model: entry,
        index: entries.indexOf(entry),
        shelfY: _shelfY(zone),
        orbitAngle: angle,
        orbitRadius: orbitRadius,
      )..behindColumn = _cameraRzForNode(
          orbitAngle: angle,
          orbitRadius: orbitRadius,
        ) >
          0);
    }
  }

  double _cameraRzForNode({
    required double orbitAngle,
    required double orbitRadius,
  }) {
    final x = math.cos(orbitAngle) * orbitRadius;
    final z = math.sin(orbitAngle) * orbitRadius;
    final cosY = math.cos(_cameraYaw);
    final sinY = math.sin(_cameraYaw);
    return x * sinY + z * cosY;
  }

  void _updateBehindState(_SceneNode node) {
    final rz = _cameraRzForNode(
      orbitAngle: node.orbitAngle,
      orbitRadius: node.orbitRadius,
    );
    const enterBehind = 24.0;
    const exitBehind = -16.0;

    if (node.behindColumn) {
      node.behindColumn = rz > exitBehind;
    } else {
      node.behindColumn = rz > enterBehind;
    }
  }

  double _frontness(double cameraRz) {
    const edge = 48.0;
    final t = (1.0 - (cameraRz / edge)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  double _shelfY(OceanDepthZone zone) {
    switch (zone) {
      case OceanDepthZone.epipelagic:
        return -0.72;
      case OceanDepthZone.mesopelagic:
        return -0.28;
      case OceanDepthZone.bathypelagic:
        return 0.28;
      case OceanDepthZone.abyssal:
        return 0.72;
    }
  }

  _Projected _project(double x, double y, double z, Size size) =>
      _SceneMath.project(
        x: x,
        y: y,
        z: z,
        cameraYaw: _cameraYaw,
        cameraPitch: _cameraPitch,
        drift: _drift,
        size: size,
      );

  int? _validSelection(List<OceanographicToolModel> entries) {
    final index = _selectedIndex;
    if (index == null || index < 0 || index >= entries.length) return null;
    return index;
  }

  void _pruneSelection(List<OceanographicToolModel> entries) {
    if (_selectedIndex != null && _validSelection(entries) == null) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    ref.listen(projectProvider, (_, _) {
      if (!mounted) return;
      final current = ref.read(projectProvider).entries;
      if (_selectedIndex != null && _validSelection(current) == null) {
        setState(() => _selectedIndex = null);
      }
    });
    _pruneSelection(entries);
    _rebuildNodes(entries);
    final selectedIndex = _validSelection(entries);
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.h;

    return Scaffold(
      backgroundColor: _deep,
      body: entries.isEmpty
          ? _buildEmpty(bottomPad)
          : Stack(
              children: [
                _buildScene(entries, bottomPad, selectedIndex),
                _buildHeader(entries.length),
                if (selectedIndex != null)
                  _buildDetailSheet(entries, selectedIndex),
              ],
            ),
    );
  }

  Widget _buildEmpty(double bottomPad) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: _mid.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: kAccent.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: CustomPaint(
                  size: Size(32.w, 64.h),
                  painter: DepthSoundingPainter(
                    depthFraction: 0.65,
                    wireColor: kAccent.withValues(alpha: 0.7),
                    classification: InstrumentClassification.soundingLead,
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Ocean map',
              style: GoogleFonts.libreBaskerville(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: _fog,
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Text(
                'Log specimens to populate the depth column — each instrument will take its place on the sounding deck.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14.sp,
                  color: kSecondaryText,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene(
    List<OceanographicToolModel> entries,
    double bottomPad,
    int? selectedIndex,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        final projected = _nodes.map((node) {
          final orbitR = node.orbitRadius;
          final x = math.cos(node.orbitAngle) * orbitR;
          final z = math.sin(node.orbitAngle) * orbitR;
          final y = node.shelfY * 170 + node.bob;
          final p = _project(x, y, z, size);
          return (node, p);
        }).toList();

        final backOrbs = projected
            .where(
              (e) => e.$1.behindColumn && selectedIndex != e.$1.index,
            )
            .toList()
          ..sort((a, b) => a.$2.depth.compareTo(b.$2.depth));
        final frontOrbs = projected
            .where(
              (e) => !e.$1.behindColumn || selectedIndex == e.$1.index,
            )
            .toList()
          ..sort((a, b) => a.$2.depth.compareTo(b.$2.depth));

        return GestureDetector(
          onPanUpdate: (d) {
            _targetYaw += d.delta.dx * 0.006;
            _targetPitch =
                (_targetPitch + d.delta.dy * 0.003).clamp(0.18, 0.62);
          },
          onDoubleTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _targetYaw = 0.55;
              _targetPitch = 0.38;
            });
          },
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _AbyssDeckPainter(
                  time: _time,
                  cameraYaw: _cameraYaw,
                  cameraPitch: _cameraPitch,
                  drift: _drift,
                  layer: _DeckLayer.background,
                ),
              ),
              ..._orbWidgets(backOrbs, behindLayer: true, selectedIndex: selectedIndex),
              CustomPaint(
                size: size,
                painter: _AbyssDeckPainter(
                  time: _time,
                  cameraYaw: _cameraYaw,
                  cameraPitch: _cameraPitch,
                  drift: _drift,
                  layer: _DeckLayer.column,
                ),
              ),
              ..._orbWidgets(frontOrbs, selectedIndex: selectedIndex),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPad + 8.h,
                child: _buildDepthLegend(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _orbWidgets(
    List<(_SceneNode, _Projected)> items, {
    bool behindLayer = false,
    int? selectedIndex,
  }) {
    return items.map((item) {
      final node = item.$1;
      final p = item.$2;
      final selected = selectedIndex == node.index;
      final orbSize = 56.w * p.scale;
      final frontness = _frontness(p.cameraRz);
      final opacity = behindLayer
          ? 0.3 + 0.2 * frontness
          : 0.55 + 0.45 * frontness;

      return Positioned(
        key: ValueKey('orb-${node.index}'),
        left: p.position.dx - orbSize / 2,
        top: p.position.dy - orbSize / 2,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedIndex = selected ? null : node.index;
            });
          },
          child: Opacity(
            opacity: opacity,
            child: _SpecimenOrb(
              node: node,
              size: orbSize,
              selected: selected,
              frontness: frontness,
              imagePath:
                  ref.watch(imageProvider).getImagePath(node.model.photoPath),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeader(int count) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.h,
      left: 20.w,
      right: 20.w,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _deep.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: kAccent.withValues(alpha: 0.35)),
                  ),
                  child: Icon(Icons.layers_outlined, color: kAccent, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ocean map',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: _fog,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        'Sounding deck · $count instruments',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.sp,
                          color: kAccent.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _deep.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _fog.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 14.sp, color: _fog.withValues(alpha: 0.6)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Drag to orbit the column · tap an instrument · double-tap to reset',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11.sp,
                            color: _fog.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepthLegend() {
    final zones = OceanDepthZone.values;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _deep.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _fog.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: zones.map((z) {
                final count = _nodes.where((n) => n.model.oceanDepthZone == z).length;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: getDepthZoneColor(z),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: getDepthZoneColor(z).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      z.label.split(' ').first,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 8.sp,
                        color: _fog.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: getDepthZoneColor(z),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSheet(
    List<OceanographicToolModel> entries,
    int selectedIndex,
  ) {
    final entry = entries[selectedIndex];
    final imgPath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final zoneColor = getDepthZoneColor(entry.oceanDepthZone);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = null),
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Transform.translate(
              offset: Offset(0, (1 - t) * 80),
              child: Opacity(opacity: t, child: child),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(
                16.w,
                0,
                16.w,
                MediaQuery.of(context).padding.bottom + 100.h,
              ),
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: kOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: zoneColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          entry.oceanDepthZone.label.split(' ').first,
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: zoneColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => _selectedIndex = null),
                        icon: Icon(Icons.close_rounded, color: kSecondaryText),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: SizedBox(
                          width: 72.w,
                          height: 72.w,
                          child: (imgPath != null && File(imgPath).existsSync())
                              ? Image.file(File(imgPath), fit: BoxFit.cover)
                              : ColoredBox(
                                  color: kAccentSurface,
                                  child: CustomPaint(
                                    painter: DepthSoundingPainter(
                                      depthFraction: getDepthFraction(
                                        entry.oceanDepthZone,
                                      ),
                                      wireColor: getInstrumentWireColor(
                                        entry.preservationSoundness,
                                      ),
                                      classification:
                                          entry.instrumentClassification,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.artisanHallmark.isNotEmpty
                                  ? entry.artisanHallmark
                                  : 'Unknown maker',
                              style: GoogleFonts.libreBaskerville(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: kPrimaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              entry.instrumentClassification.label,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12.sp,
                                color: kSecondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (entry.soundingPressureBounds.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Text(
                      entry.soundingPressureBounds,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: kAccent,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/info_screen',
                          arguments: {'index': selectedIndex},
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimaryText,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Open full record',
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecimenOrb extends StatelessWidget {
  final _SceneNode node;
  final double size;
  final bool selected;
  final double frontness;
  final String? imagePath;

  const _SpecimenOrb({
    required this.node,
    required this.size,
    required this.selected,
    required this.frontness,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final zoneColor = getDepthZoneColor(node.model.oceanDepthZone);
    final wireColor = getInstrumentWireColor(node.model.preservationSoundness);
    final borderColor = selected
        ? _fog
        : Color.lerp(
            wireColor.withValues(alpha: 0.3),
            wireColor.withValues(alpha: 0.85),
            frontness,
          )!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: zoneColor.withValues(
              alpha: (selected ? 0.55 : 0.22 + 0.18 * frontness),
            ),
            blurRadius: selected ? 24 : 10 + 6 * frontness,
            spreadRadius: selected ? 2 : 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2 + 0.15 * frontness),
            blurRadius: 10,
            offset: Offset(0, size * 0.08),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: selected ? 2.5 : 1.5,
        ),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null && File(imagePath!).existsSync())
              Image.file(File(imagePath!), fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      wireColor.withValues(alpha: 0.9),
                      zoneColor.withValues(alpha: 0.75),
                      _deep,
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _GlyphPainter(node.model.instrumentClassification),
                ),
              ),
            if (selected)
              Container(
                color: kAccent.withValues(alpha: 0.12),
              ),
          ],
        ),
      ),
    );
  }
}

enum _DeckLayer { background, column }

class _ColumnFace {
  final List<Offset> points;
  final double depth;
  final double cameraRz;
  final double heightT;
  final bool isCap;
  final bool isTop;

  const _ColumnFace({
    required this.points,
    required this.depth,
    required this.cameraRz,
    required this.heightT,
    this.isCap = false,
    this.isTop = false,
  });
}

class _AbyssDeckPainter extends CustomPainter {
  final double time;
  final double cameraYaw;
  final double cameraPitch;
  final double drift;
  final _DeckLayer layer;

  _AbyssDeckPainter({
    required this.time,
    required this.cameraYaw,
    required this.cameraPitch,
    required this.drift,
    required this.layer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layer == _DeckLayer.background) {
      final rect = Offset.zero & size;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_shallow, _mid, _deep, _abyss],
            stops: [0.0, 0.28, 0.62, 1.0],
          ).createShader(rect),
      );
      _drawCaustics(canvas, size);
      _drawGrid(canvas, size);
      _drawParticles(canvas, size);
      return;
    }

    _drawColumn3D(canvas, size);
    _drawShelfRings(canvas, size);
  }

  void _drawCaustics(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < 5; i++) {
      final phase = time * 0.4 + i * 1.3;
      final cx = size.width * (0.2 + i * 0.15) + math.sin(phase) * 30;
      final cy = size.height * 0.18 + math.cos(phase * 0.7) * 20;
      paint.shader = RadialGradient(
        colors: [
          kAccent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 90));
      canvas.drawCircle(Offset(cx, cy), 90, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _fog.withValues(alpha: 0.04)
      ..strokeWidth = 0.6;
    for (var y = 0.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var x = 0.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  Offset _proj(double x, double y, double z, Size size) =>
      _SceneMath.project(
        x: x,
        y: y,
        z: z,
        cameraYaw: cameraYaw,
        cameraPitch: cameraPitch,
        drift: drift,
        size: size,
      ).position;

  double _cameraRz(double x, double y, double z) {
    final cosY = math.cos(cameraYaw);
    final sinY = math.sin(cameraYaw);
    return x * sinY + z * cosY;
  }

  void _drawColumn3D(Canvas canvas, Size size) {
    const heightSegments = 20;
    const thetaSegments = 28;
    final topR = 42.0;
    final botR = 110.0;
    final height = size.height * 0.72;

    final faces = <_ColumnFace>[];

    for (var s = 0; s < heightSegments; s++) {
      final t0 = s / heightSegments;
      final t1 = (s + 1) / heightSegments;
      final y0 = -height / 2 + height * t0;
      final y1 = -height / 2 + height * t1;
      final r0 = topR + (botR - topR) * t0;
      final r1 = topR + (botR - topR) * t1;

      for (var t = 0; t < thetaSegments; t++) {
        final a0 = (t / thetaSegments) * math.pi * 2;
        final a1 = ((t + 1) / thetaSegments) * math.pi * 2;
        final midA = (a0 + a1) / 2;

        final x00 = math.cos(a0) * r0;
        final z00 = math.sin(a0) * r0;
        final x01 = math.cos(a1) * r0;
        final z01 = math.sin(a1) * r0;
        final x10 = math.cos(a0) * r1;
        final z10 = math.sin(a0) * r1;
        final x11 = math.cos(a1) * r1;
        final z11 = math.sin(a1) * r1;

        final midR = (r0 + r1) / 2;
        final midX = math.cos(midA) * midR;
        final midZ = math.sin(midA) * midR;
        final midY = (y0 + y1) / 2;
        final rz = _cameraRz(midX, midY, midZ);

        faces.add(_ColumnFace(
          points: [
            _proj(x00, y0, z00, size),
            _proj(x01, y0, z01, size),
            _proj(x11, y1, z11, size),
            _proj(x10, y1, z10, size),
          ],
          depth: _SceneMath.project(
            x: midX,
            y: midY,
            z: midZ,
            cameraYaw: cameraYaw,
            cameraPitch: cameraPitch,
            drift: drift,
            size: size,
          ).depth,
          cameraRz: rz,
          heightT: t0,
        ));
      }
    }

    _addCapFaces(
      faces,
      y: -height / 2,
      radius: topR,
      size: size,
      isTop: true,
    );
    _addCapFaces(
      faces,
      y: height / 2,
      radius: botR,
      size: size,
      isTop: false,
    );

    faces.sort((a, b) => a.depth.compareTo(b.depth));

    for (final face in faces) {
      if (!_isFrontFacing(face.points)) continue;

      final isBack = face.cameraRz > 0;
      final Color shade;
      if (face.isCap) {
        shade = face.isTop
            ? kAccent.withValues(alpha: isBack ? 0.2 : 0.38)
            : Color.lerp(
                kSecondaryAccent.withValues(alpha: isBack ? 0.16 : 0.32),
                _abyss,
                0.35,
              )!;
      } else {
        shade = Color.lerp(
          kAccent.withValues(alpha: isBack ? 0.18 : 0.42),
          _abyss,
          face.heightT,
        )!;
      }

      final path = Path()
        ..moveTo(face.points[0].dx, face.points[0].dy)
        ..lineTo(face.points[1].dx, face.points[1].dy)
        ..lineTo(face.points[2].dx, face.points[2].dy);
      if (face.points.length == 4) {
        path.lineTo(face.points[3].dx, face.points[3].dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = shade);

      if (!isBack && !face.isCap) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _fog.withValues(alpha: 0.06)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
      } else if (face.isCap && !isBack) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _fog.withValues(alpha: face.isTop ? 0.1 : 0.07)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
    }
  }

  void _addCapFaces(
    List<_ColumnFace> faces, {
    required double y,
    required double radius,
    required Size size,
    required bool isTop,
  }) {
    const segments = 32;
    final center = _proj(0, y, 0, size);

    for (var i = 0; i < segments; i++) {
      final a0 = (i / segments) * math.pi * 2;
      final a1 = ((i + 1) / segments) * math.pi * 2;
      final x0 = math.cos(a0) * radius;
      final z0 = math.sin(a0) * radius;
      final x1 = math.cos(a1) * radius;
      final z1 = math.sin(a1) * radius;
      final midA = (a0 + a1) / 2;
      final midX = math.cos(midA) * radius * 0.55;
      final midZ = math.sin(midA) * radius * 0.55;

      final p0 = _proj(x0, y, z0, size);
      final p1 = _proj(x1, y, z1, size);
      final points = isTop ? [center, p1, p0] : [center, p0, p1];

      faces.add(_ColumnFace(
        points: points,
        depth: _SceneMath.project(
          x: midX,
          y: y,
          z: midZ,
          cameraYaw: cameraYaw,
          cameraPitch: cameraPitch,
          drift: drift,
          size: size,
        ).depth,
        cameraRz: _cameraRz(midX, y, midZ),
        heightT: isTop ? 0.0 : 1.0,
        isCap: true,
        isTop: isTop,
      ));
    }
  }

  bool _isFrontFacing(List<Offset> points) {
    if (points.length < 3) return false;
    double sum = 0;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      sum += (b.dx - a.dx) * (b.dy + a.dy);
    }
    return sum < 0;
  }

  void _drawShelfRings(Canvas canvas, Size size) {
    final shelves = [
      (-0.72, '0–200 m', OceanDepthZone.epipelagic),
      (-0.28, '200–1k', OceanDepthZone.mesopelagic),
      (0.28, '1k–4k', OceanDepthZone.bathypelagic),
      (0.72, 'Abyssal', OceanDepthZone.abyssal),
    ];

    for (final (yNorm, label, zone) in shelves) {
      final y = yNorm * 170;
      final ringR = 128.0;
      final color = getDepthZoneColor(zone);
      final points = <Offset>[];
      for (var i = 0; i <= 48; i++) {
        final a = (i / 48) * math.pi * 2;
        points.add(_proj(math.cos(a) * ringR, y, math.sin(a) * ringR, size));
      }
      canvas.drawPath(
        Path()..addPolygon(points, true),
        Paint()
          ..color = color.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final labelPos = _proj(ringR + 28, y, 0, size);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color.withValues(alpha: 0.65),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(0, tp.height / 2));
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final rand = math.Random(9);
    for (var i = 0; i < 40; i++) {
      final bx = rand.nextDouble() * size.width;
      final by = (rand.nextDouble() * size.height + time * 18 * (i % 3 + 1)) %
          size.height;
      final alpha = 0.04 + (i % 5) * 0.02;
      canvas.drawCircle(
        Offset(bx, by),
        1.2 + i % 3,
        Paint()..color = _fog.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AbyssDeckPainter old) => true;
}

class _GlyphPainter extends CustomPainter {
  final InstrumentClassification type;
  _GlyphPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = _fog.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    switch (type) {
      case InstrumentClassification.soundingLead:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy + 4), width: 22, height: 10),
          paint,
        );
        break;
      case InstrumentClassification.reversingThermometer:
        canvas.drawLine(const Offset(-5, -8), const Offset(-5, 8), paint);
        canvas.drawLine(const Offset(5, -8), const Offset(5, 8), paint);
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 18),
            const Radius.circular(3),
          ),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.type != type;
}
