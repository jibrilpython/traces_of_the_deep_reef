import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class ReefFloatingNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ReefNavTab> tabs;

  const ReefFloatingNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: kPrimaryText.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final selected = currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? kPrimaryText : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 21.sp,
                      color: selected ? Colors.white : kSecondaryText,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      tab.label,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 10.sp,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? Colors.white : kSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ReefNavTab {
  final IconData icon;
  final String label;
  const ReefNavTab(this.icon, this.label);
}

class ReefStepProgress extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const ReefStepProgress({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: Container(
                        height: 2,
                        color: i <= currentStep ? kAccent : kOutline,
                      ),
                    ),
                  ),
                _StepDot(
                  index: i,
                  isDone: i < currentStep,
                  isCurrent: i == currentStep,
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              for (int i = 0; i < labels.length; i++)
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11.sp,
                      fontWeight:
                          i == currentStep ? FontWeight.w600 : FontWeight.w400,
                      color: i == currentStep ? kAccent : kSecondaryText,
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

class _StepDot extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isCurrent;

  const _StepDot({
    required this.index,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final active = isDone || isCurrent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: active ? kAccent : kPanelBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? kAccent : kOutline,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
            : Text(
                '${index + 1}',
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? Colors.white : kSecondaryText,
                ),
              ),
      ),
    );
  }
}

class ReefFormBottomBar extends StatelessWidget {
  final bool showBack;
  final String primaryLabel;
  final VoidCallback? onBack;
  final VoidCallback? onPrimary;
  final bool floating;

  const ReefFormBottomBar({
    super.key,
    required this.showBack,
    required this.primaryLabel,
    this.onBack,
    this.onPrimary,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final buttonRadius = BorderRadius.circular(14.r);

    Widget backButton() => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: buttonRadius,
            boxShadow: floating
                ? [
                    BoxShadow(
                      color: kPrimaryText.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryText,
              backgroundColor: floating ? kPanelBg : null,
              side: const BorderSide(color: kOutline),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            ),
            child: Text(
              'Back',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );

    Widget primaryButton() => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: buttonRadius,
            boxShadow: floating
                ? [
                    BoxShadow(
                      color: kPrimaryText.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: buttonRadius),
              elevation: 0,
            ),
            child: Text(
              primaryLabel,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

    final buttons = Row(
      children: [
        if (showBack) ...[
          Expanded(child: backButton()),
          SizedBox(width: 10.w),
        ],
        Expanded(
          flex: showBack ? 2 : 1,
          child: primaryButton(),
        ),
      ],
    );

    if (floating) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottom + 12.h),
        child: buttons,
      );
    }

    final bar = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border.all(color: kOutline),
      ),
      child: buttons,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, bottom + 12.h),
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border(top: BorderSide(color: kOutline)),
      ),
      child: bar,
    );
  }
}

class ReefLogFab extends StatelessWidget {
  final VoidCallback onTap;

  const ReefLogFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w, bottom: 4.h),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: kPrimaryText.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Material(
              color: kPrimaryText,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Log specimen',
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReefSectionLabel extends StatelessWidget {
  final String text;
  const ReefSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: kSecondaryText,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class ReefSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const ReefSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Material(
        color: kPanelBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(
            color: focused ? kAccent : kOutline,
            width: focused ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: GoogleFonts.ibmPlexSans(fontSize: 15.sp, color: kPrimaryText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.ibmPlexSans(
              fontSize: 14.sp,
              color: kSecondaryText.withValues(alpha: 0.55),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: focused ? kAccent : kSecondaryText,
              size: 22.sp,
            ),
            suffixIcon: onClear != null
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: kSecondaryText),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}
