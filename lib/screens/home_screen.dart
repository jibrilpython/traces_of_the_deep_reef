import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/common/archive_empty_illustration.dart';
import 'package:traces_of_the_deep_reef/common/app_chrome.dart';
import 'package:traces_of_the_deep_reef/common/depth_sounding_painter.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/providers/input_provider.dart';
import 'package:traces_of_the_deep_reef/providers/project_provider.dart';
import 'package:traces_of_the_deep_reef/providers/search_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  OceanDepthZone? _selectedZone;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final allEntries = ref.watch(projectProvider).entries;
    final filterText = searchProv.searchQuery.toLowerCase();

    final entries = allEntries.where((e) {
      final matchesSearch = filterText.isEmpty ||
          e.artisanHallmark.toLowerCase().contains(filterText) ||
          e.oceanicRegistryLog.toLowerCase().contains(filterText) ||
          e.instrumentClassification.label.toLowerCase().contains(filterText) ||
          e.expeditionGroundZero.toLowerCase().contains(filterText);
      final matchesZone =
          _selectedZone == null || e.oceanDepthZone == _selectedZone;
      return matchesSearch && matchesZone;
    }).toList();

    final navClearance =
        MediaQuery.of(context).padding.bottom + 96.h;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: 14.h),
                      _buildDepthZoneFilter(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14.h,
                      crossAxisSpacing: 14.w,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final mainIndex = allEntries.indexOf(entry);
                        return _buildCard(entry, mainIndex);
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(height: navClearance + 72.h),
              ),
            ],
          ),
          Positioned(
            right: 20.w,
            bottom: navClearance,
            child: ReefLogFab(
              onTap: () {
                ref.read(inputProvider).clearAll();
                ref.read(imageProvider).clearImage();
                Navigator.pushNamed(context, '/add_screen');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(int count) {
    final makers = ref.watch(projectProvider).entries
        .map((e) => e.artisanHallmark)
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;

    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 148.h,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: kBackground,
          padding: EdgeInsets.fromLTRB(
            20.w,
            MediaQuery.of(context).padding.top + 12.h,
            20.w,
            12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13.r),
                      child: Image.asset(
                        'assets/images/icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.anchor_rounded,
                          color: kAccent,
                          size: 22.sp,
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
                          'Archive',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: kPrimaryText,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Traces of the Deep Reef',
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
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
                          'items',
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
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: kOutline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _headerStat(
                        Icons.inventory_2_outlined,
                        '$count specimens',
                      ),
                    ),
                    Container(width: 1, height: 20.h, color: kOutline),
                    Expanded(
                      child: _headerStat(
                        Icons.storefront_outlined,
                        '$makers makers',
                      ),
                    ),
                    Container(width: 1, height: 20.h, color: kOutline),
                    Expanded(
                      child: _headerStat(
                        Icons.waves_outlined,
                        'Depth-sorted',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerStat(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14.sp, color: kSecondaryText),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11.sp,
              color: kSecondaryText,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ReefSearchField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: 'Search makers, registry codes, voyages…',
      onChanged: (v) => ref.read(searchProvider.notifier).setSearchQuery(v),
      onClear: _searchController.text.isNotEmpty
          ? () {
              _searchController.clear();
              ref.read(searchProvider.notifier).setSearchQuery('');
              setState(() {});
            }
          : null,
    );
  }

  Widget _buildDepthZoneFilter() {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _zoneChip(null, 'All zones'),
          ...OceanDepthZone.values.map(
            (z) => _zoneChip(z, z.label.split(' ').first),
          ),
        ],
      ),
    );
  }

  Widget _zoneChip(OceanDepthZone? zone, String label) {
    final selected = _selectedZone == zone;
    final color = zone != null ? getDepthZoneColor(zone) : kPrimaryText;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedZone = zone),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? color : kSecondaryText,
        ),
        backgroundColor: kPanelBg,
        selectedColor: color.withValues(alpha: 0.12),
        side: BorderSide(color: selected ? color : kOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        showCheckmark: false,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ArchiveEmptyIllustration(),
        SizedBox(height: 24.h),
        Text(
          'No specimens in this archive',
          style: GoogleFonts.ibmPlexSans(
            color: kSecondaryText,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap Log specimen to add your first instrument',
          style: GoogleFonts.ibmPlexSans(
            color: kSecondaryText.withValues(alpha: 0.7),
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  String _yearLabel(String era) {
    final trimmed = era.trim();
    if (trimmed.isEmpty) return '';
    final years = RegExp(r'\d{4}')
        .allMatches(trimmed)
        .map((m) => m.group(0)!)
        .toList();
    if (years.isEmpty) return trimmed.length <= 14 ? trimmed : '';
    if (years.length == 1) return years.first;
    return '${years.first}–${years.last}';
  }

  Widget _buildCard(OceanographicToolModel entry, int mainIndex) {
    final imagePath =
        ref.watch(imageProvider).getImagePath(entry.photoPath);
    final zoneColor = getDepthZoneColor(entry.oceanDepthZone);
    final wireColor = getInstrumentWireColor(entry.preservationSoundness);
    final depthFrac = getDepthFraction(entry.oceanDepthZone);
    final yearLabel = _yearLabel(entry.era);

    return Material(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': mainIndex},
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: kSecondaryText.withValues(alpha: 0.28),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (imagePath != null && File(imagePath).existsSync())
                        ? Image.file(File(imagePath), fit: BoxFit.cover)
                        : ColoredBox(
                            color: kAccentSurface.withValues(alpha: 0.4),
                            child: Center(
                              child: CustomPaint(
                                size: Size(24.w, 48.h),
                                painter: DepthSoundingPainter(
                                  depthFraction: depthFrac,
                                  wireColor: wireColor,
                                  classification:
                                      entry.instrumentClassification,
                                ),
                              ),
                            ),
                          ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: zoneColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          entry.oceanDepthZone.label.split(' ').first,
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.artisanHallmark.isNotEmpty
                            ? entry.artisanHallmark
                            : 'Unknown maker',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryText,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.instrumentClassification.label,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11.sp,
                          color: kSecondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (yearLabel.isNotEmpty) ...[
                            Icon(
                              Icons.schedule_outlined,
                              size: 11.sp,
                              color: kSecondaryAccent,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              yearLabel,
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 10.sp,
                                color: kSecondaryAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (entry.soundingPressureBounds.isNotEmpty)
                            Flexible(
                              child: Text(
                                entry.soundingPressureBounds,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 9.sp,
                                  color: kAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
