import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/common/app_chrome.dart';
import 'package:traces_of_the_deep_reef/common/photo_bottom_sheet.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/providers/input_provider.dart';
import 'package:traces_of_the_deep_reef/providers/project_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late PageController _pageCtrl;
  int _currentPage = 0;

  late TextEditingController _registryCtrl;
  late TextEditingController _hallmarkCtrl;
  late TextEditingController _eraCtrl;
  late TextEditingController _calibrationCtrl;
  late TextEditingController _boundsCtrl;
  late TextEditingController _ballastCtrl;
  late TextEditingController _proportionsCtrl;
  late TextEditingController _marksCtrl;
  late TextEditingController _expeditionCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    final registryText = !widget.isEdit && p.oceanicRegistryLog.isEmpty
        ? generateRegistryCode()
        : p.oceanicRegistryLog;
    _registryCtrl = TextEditingController(text: registryText);
    _hallmarkCtrl = TextEditingController(text: p.artisanHallmark);
    _eraCtrl = TextEditingController(text: p.era);
    _calibrationCtrl = TextEditingController(text: p.calibrationSite);
    _boundsCtrl = TextEditingController(text: p.soundingPressureBounds);
    _ballastCtrl = TextEditingController(text: p.ballastMassProfile);
    _proportionsCtrl = TextEditingController(text: p.physicalProportions);
    _marksCtrl = TextEditingController(text: p.calibrationMarks);
    _expeditionCtrl = TextEditingController(text: p.expeditionGroundZero);
    _notesCtrl = TextEditingController(text: p.notes);

    if (!widget.isEdit && p.oceanicRegistryLog.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(inputProvider).oceanicRegistryLog = registryText;
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _registryCtrl,
      _hallmarkCtrl,
      _eraCtrl,
      _calibrationCtrl,
      _boundsCtrl,
      _ballastCtrl,
      _proportionsCtrl,
      _marksCtrl,
      _expeditionCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int page) => _pageCtrl.animateToPage(
        page,
        duration: const Duration(milliseconds: 270),
        curve: Curves.easeOut,
      );

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: GoogleFonts.ibmPlexMono(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: kError,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(20.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusSubtle),
      ),
    ));
  }

  void _save() async {
    final p = ref.read(inputProvider);
    p.oceanicRegistryLog = _registryCtrl.text.trim();
    p.artisanHallmark = _hallmarkCtrl.text;
    p.era = _eraCtrl.text;
    p.calibrationSite = _calibrationCtrl.text;
    p.soundingPressureBounds = _boundsCtrl.text;
    p.ballastMassProfile = _ballastCtrl.text;
    p.physicalProportions = _proportionsCtrl.text;
    p.calibrationMarks = _marksCtrl.text;
    p.expeditionGroundZero = _expeditionCtrl.text;
    p.notes = _notesCtrl.text;

    if (_registryCtrl.text.trim().isEmpty) {
      _showError('Oceanic registry log is required');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1100));

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: kPrimaryText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit specimen' : 'Log specimen',
          style: GoogleFonts.libreBaskerville(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ReefStepProgress(
                currentStep: _currentPage,
                labels: const ['Identity', 'Mechanics', 'Archive'],
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ReefFormBottomBar(
              floating: true,
              showBack: _currentPage > 0,
              primaryLabel: _currentPage < 2
                  ? 'Continue'
                  : (widget.isEdit ? 'Save changes' : 'Save to archive'),
              onBack: () => _goToPage(_currentPage - 1),
              onPrimary: () {
                if (_currentPage < 2) {
                  _goToPage(_currentPage + 1);
                } else {
                  _save();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Identification'),
          SizedBox(height: 24.h),
          _buildPhotoSection(),
          SizedBox(height: 28.h),
          _monoField(
            label: 'Oceanic registry log',
            ctrl: _registryCtrl,
            hint: 'Auto-generated on save if left blank',
            onChanged: (v) => ref.read(inputProvider).oceanicRegistryLog = v,
          ),
          _buildEnumGroup<InstrumentClassification>(
            label: 'Instrument classification',
            values: InstrumentClassification.values,
            current: ref.watch(inputProvider).instrumentClassification,
            onSelected: (t) =>
                ref.read(inputProvider).instrumentClassification = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'Artisan hallmark',
            ctrl: _hallmarkCtrl,
            hint: 'e.g. Nautilus Scientific Instrument Co.',
            onChanged: (v) => ref.read(inputProvider).artisanHallmark = v,
          ),
          _monoField(
            label: 'Era',
            ctrl: _eraCtrl,
            hint: 'e.g. 1870s',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9s]')),
              _EraInputFormatter(),
            ],
            onChanged: (v) => ref.read(inputProvider).era = v,
          ),
          _monoField(
            label: 'Calibration site',
            ctrl: _calibrationCtrl,
            hint: 'e.g. IronAnchor Brassworks, Sheffield',
            onChanged: (v) => ref.read(inputProvider).calibrationSite = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Depth & mechanics'),
          SizedBox(height: 24.h),
          _buildEnumGroup<OceanDepthZone>(
            label: 'Operating depth zone',
            values: OceanDepthZone.values,
            current: ref.watch(inputProvider).oceanDepthZone,
            onSelected: (t) => ref.read(inputProvider).oceanDepthZone = t,
            labelBuilder: (t) => t.label,
          ),
          _buildEnumGroup<ValvingSealingMechanics>(
            label: 'Valving & sealing mechanics',
            values: ValvingSealingMechanics.values,
            current: ref.watch(inputProvider).valvingSealingMechanics,
            onSelected: (t) =>
                ref.read(inputProvider).valvingSealingMechanics = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'Sounding & pressure bounds',
            ctrl: _boundsCtrl,
            hint: 'e.g. 500 Fathoms, 100 Atmospheres',
            onChanged: (v) => ref.read(inputProvider).soundingPressureBounds = v,
          ),
          _buildEnumGroup<CompositionMetallurgy>(
            label: 'Composition metallurgy',
            values: CompositionMetallurgy.values,
            current: ref.watch(inputProvider).compositionMetallurgy,
            onSelected: (t) => ref.read(inputProvider).compositionMetallurgy = t,
            labelBuilder: (t) => t.label,
          ),
          _monoField(
            label: 'Ballast & mass profile',
            ctrl: _ballastCtrl,
            hint: 'e.g. 14-lb split-lead weight',
            onChanged: (v) => ref.read(inputProvider).ballastMassProfile = v,
          ),
          _monoField(
            label: 'Physical proportions',
            ctrl: _proportionsCtrl,
            hint: 'e.g. 420 mm sleeve, 3.2 kg dry weight',
            onChanged: (v) => ref.read(inputProvider).physicalProportions = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader('Archival record'),
          SizedBox(height: 24.h),
          _buildEnumGroup<PreservationSoundness>(
            label: 'Preservation soundness',
            values: PreservationSoundness.values,
            current: ref.watch(inputProvider).preservationSoundness,
            onSelected: (t) => ref.read(inputProvider).preservationSoundness = t,
            labelBuilder: (t) => t.label.split(' — ')[0],
          ),
          _monoField(
            label: 'Calibration marks & stamps',
            ctrl: _marksCtrl,
            hint: 'Foundry marks, serial numbers, kiln stamps...',
            maxLines: 2,
            onChanged: (v) => ref.read(inputProvider).calibrationMarks = v,
          ),
          _monoField(
            label: 'Expedition ground zero',
            ctrl: _expeditionCtrl,
            hint: 'e.g. Historic North Atlantic current mapping',
            onChanged: (v) => ref.read(inputProvider).expeditionGroundZero = v,
          ),
          _monoField(
            label: 'Archival notes',
            ctrl: _notesCtrl,
            hint: 'Expedition history, field observations...',
            maxLines: 5,
            onChanged: (v) => ref.read(inputProvider).notes = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.libreBaskerville(
        color: kPrimaryText,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildPhotoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 170.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: kOutline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Image.file(File(imgPath), fit: BoxFit.cover)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: kSecondaryText.withValues(alpha: 0.4),
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap to add photograph',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _monoField({
    required String label,
    required TextEditingController ctrl,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.ibmPlexSans(
              color: kPrimaryText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ibmPlexSans(
                color: kSecondaryText.withValues(alpha: 0.35),
                fontSize: 13.sp,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kOutline, width: 1.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccent, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnumGroup<T>({
    required String label,
    required List<T> values,
    required T current,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: values.map((val) {
              final isSel = val == current;
              return GestureDetector(
                onTap: () => onSelected(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSel ? kAccent : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(
                      color: isSel ? kAccent : kOutline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    labelBuilder(val),
                    style: GoogleFonts.ibmPlexSans(
                      color: isSel ? Colors.white : kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44.w,
              height: 44.w,
              child: const CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              'Saving to archive',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Recording specimen data to the oceanographic archive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final regExp = RegExp(r'^\d{0,4}s?$');
    if (regExp.hasMatch(text)) return newValue;
    return oldValue;
  }
}
