import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/common/depth_sounding_painter.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';
import 'package:traces_of_the_deep_reef/providers/project_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  double _bottomPad(BuildContext context) =>
      96.h + MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildHeader(entries.length),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, _bottomPad(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroCard(entries),
                  SizedBox(height: 16.h),
                  _buildMetricGrid(entries),
                  SizedBox(height: 20.h),
                  _LogbookCard(
                    title: 'Depth zones',
                    subtitle: 'Rated operating depths across the archive',
                    child: _buildDepthZones(entries),
                  ),
                  SizedBox(height: 16.h),
                  _LogbookCard(
                    title: 'Instrument types',
                    subtitle: 'Classification breakdown',
                    child: _buildInstrumentRankings(entries),
                  ),
                  SizedBox(height: 16.h),
                  _LogbookCard(
                    title: 'Preservation',
                    subtitle: 'Condition across the collection',
                    child: _buildPreservation(entries),
                  ),
                  SizedBox(height: 16.h),
                  _LogbookCard(
                    title: 'Metallurgy',
                    subtitle: 'Material composition inventory',
                    child: _buildMetallurgy(entries),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          MediaQuery.of(context).padding.top + 16.h,
          20.w,
          8.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: kOutline),
              ),
              child: Icon(Icons.bar_chart_rounded, color: kAccent, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logbook',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryText,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Collection insights & trends',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.sp,
                      color: kAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kOutline),
              ),
              child: Column(
                children: [
                  Text(
                    count.toString().padLeft(2, '0'),
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
                  ),
                  Text(
                    'logged',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10.sp,
                      color: kSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(List<OceanographicToolModel> entries) {
    final total = entries.length;
    final healthPct = _preservationScore(entries);
    final makers = entries
        .map((e) => e.artisanHallmark)
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
    final zones = entries.map((e) => e.oceanDepthZone).toSet().length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAccent, kAccentLight],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: kAccent.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archive overview',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  total.toString(),
                  style: GoogleFonts.libreBaskerville(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'specimens catalogued',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _heroPill('$makers makers'),
                    SizedBox(width: 8.w),
                    _heroPill('$zones depth zones'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          _HealthRing(percent: healthPct, animation: _animation),
        ],
      ),
    );
  }

  Widget _heroPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetricGrid(List<OceanographicToolModel> entries) {
    final yearRange = _getYearRange(entries);
    final sites = entries
        .map((e) => e.calibrationSite)
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;
    final dominant = _dominantDepthZone(entries);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10.h,
      crossAxisSpacing: 10.w,
      childAspectRatio: 1.55,
      children: [
        _MetricTile(
          icon: Icons.calendar_today_outlined,
          label: 'Era span',
          value: yearRange,
        ),
        _MetricTile(
          icon: Icons.location_on_outlined,
          label: 'Calibration sites',
          value: sites.toString(),
        ),
        _MetricTile(
          icon: Icons.category_outlined,
          label: 'Instrument types',
          value: _uniqueTypes(entries).toString(),
        ),
        _MetricTile(
          icon: Icons.waves_outlined,
          label: 'Dominant zone',
          value: dominant?.label.split(' ').first ?? '—',
          accent: dominant != null ? getDepthZoneColor(dominant) : kAccent,
        ),
      ],
    );
  }

  Widget _buildDepthZones(List<OceanographicToolModel> entries) {
    final counts = _countBy(entries, (e) => e.oceanDepthZone);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: sorted.map((item) {
            final color = getDepthZoneColor(item.key);
            final frac = (item.value / max) * _animation.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          item.key.label,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13.sp,
                            color: kPrimaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        item.value.toString(),
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: frac,
                      minHeight: 8.h,
                      backgroundColor: kOutline,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInstrumentRankings(List<OceanographicToolModel> entries) {
    final counts = _countBy(entries, (e) => e.instrumentClassification);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.isEmpty ? 1 : sorted.first.value;
    final total = entries.length;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: List.generate(sorted.length, (i) {
            final item = sorted[i];
            final pct = total == 0 ? 0.0 : item.value / total;
            final barFrac = (item.value / max) * _animation.value;
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i == sorted.length - 1 ? 0 : 12.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 22.w,
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 12.sp,
                        color: kSecondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.key.label,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13.sp,
                                  color: kPrimaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(pct * 100).round()}%',
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 11.sp,
                                color: kSecondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: barFrac,
                            minHeight: 6.h,
                            backgroundColor: kAccentSurface,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    item.value.toString(),
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPreservation(List<OceanographicToolModel> entries) {
    final counts = _countBy(entries, (e) => e.preservationSoundness);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            height: 14.h,
            child: Row(
              children: sorted.map((item) {
                final frac = total == 0 ? 0.0 : item.value / total;
                if (frac <= 0) return const SizedBox.shrink();
                return Expanded(
                  flex: (frac * 1000).round().clamp(1, 1000),
                  child: ColoredBox(
                    color: getConditionColor(item.key),
                    child: const SizedBox.expand(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ...sorted.map((item) {
          final color = getConditionColor(item.key);
          final pct = total == 0 ? 0.0 : item.value / total;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.key.label.split(' — ').first,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.sp,
                      color: kPrimaryText,
                    ),
                  ),
                ),
                Text(
                  '${item.value} · ${(pct * 100).round()}%',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetallurgy(List<OceanographicToolModel> entries) {
    final counts = _countBy(entries, (e) => e.compositionMetallurgy);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: sorted.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: kBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.value.toString(),
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: kSecondaryAccent,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  item.key.label,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.sp,
                    color: kPrimaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: kOutline),
            ),
            child: Center(
              child: CustomPaint(
                size: Size(28.w, 56.h),
                painter: DepthSoundingPainter(
                  depthFraction: 0.5,
                  wireColor: kAccent.withValues(alpha: 0.5),
                  classification: InstrumentClassification.soundingLead,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No data yet',
            style: GoogleFonts.libreBaskerville(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: kPrimaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Log your first specimen from the Archive tab to populate the logbook.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14.sp,
              color: kSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  int _preservationScore(List<OceanographicToolModel> entries) {
    final total = entries.length;
    if (total == 0) return 0;
    final goodCount = entries
        .where((e) =>
            e.preservationSoundness == PreservationSoundness.museumGrade ||
            e.preservationSoundness == PreservationSoundness.operational)
        .length;
    return (goodCount / total * 100).round();
  }

  String _getYearRange(List<OceanographicToolModel> entries) {
    final years = <int>[];
    final regex = RegExp(r'\d{4}');
    for (final e in entries) {
      for (final m in regex.allMatches(e.era)) {
        final year = int.tryParse(m.group(0)!);
        if (year != null) years.add(year);
      }
    }
    if (years.isEmpty) return '—';
    years.sort();
    return years.first == years.last
        ? years.first.toString()
        : '${years.first}–${years.last}';
  }

  Map<T, int> _countBy<T>(
    List<OceanographicToolModel> entries,
    T Function(OceanographicToolModel) key,
  ) {
    final counts = <T, int>{};
    for (final e in entries) {
      final k = key(e);
      counts[k] = (counts[k] ?? 0) + 1;
    }
    return counts;
  }

  int _uniqueTypes(List<OceanographicToolModel> entries) =>
      entries.map((e) => e.instrumentClassification).toSet().length;

  OceanDepthZone? _dominantDepthZone(List<OceanographicToolModel> entries) {
    final counts = _countBy(entries, (e) => e.oceanDepthZone);
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class _LogbookCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _LogbookCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: GoogleFonts.libreBaskerville(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: kPrimaryText,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12.sp,
              color: kSecondaryText,
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = kAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20.sp, color: accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11.sp,
                  color: kSecondaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  final int percent;
  final Animation<double> animation;

  const _HealthRing({required this.percent, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return SizedBox(
          width: 72.w,
          height: 72.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(72.w, 72.w),
                painter: _RingPainter(
                  progress: (percent / 100) * t,
                  trackColor: Colors.white.withValues(alpha: 0.2),
                  progressColor: Colors.white,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(percent * t).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'health',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const stroke = 5.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
