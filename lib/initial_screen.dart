import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traces_of_the_deep_reef/providers/user_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  void _enterArchive(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(userProvider).setFirstTimeUser(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28.w, 48.h, 28.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traces of',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3.5,
                      ),
                    ),
                    Text(
                      'the Deep\nReef.',
                      style: GoogleFonts.libreBaskerville(
                        color: kPrimaryText,
                        fontSize: 52.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.95,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      width: 40.w,
                      height: 2,
                      color: kAccent.withValues(alpha: 0.45),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'A digital archive for oceanographic instruments that mapped the abyss before digital sonar.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w300,
                        height: 1.65,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: kOutline),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryText.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: kOutline,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: kAccentSurface,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: kAccent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 18.sp,
                            color: kAccent,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: kOutline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Catalogue reversing thermometers, sounding leads, and the apparatus of the deep.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _enterArchive(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Enter the archive',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
