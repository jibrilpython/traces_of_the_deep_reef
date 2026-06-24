import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: kOutline),
          boxShadow: [
            BoxShadow(
              color: kPrimaryText.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add photograph',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: kPrimaryText,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Document the instrument on white or pale grey',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13.sp,
                            color: kSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded, color: kSecondaryText),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              child: Column(
                children: [
                  _PhotoAction(
                    icon: Icons.camera_alt_outlined,
                    title: 'Take photo',
                    subtitle: 'Use your camera',
                    onTap: () async {
                      Navigator.pop(ctx);
                      await imageProv.pickImage(source: ImageSource.camera);
                    },
                  ),
                  SizedBox(height: 10.h),
                  _PhotoAction(
                    icon: Icons.photo_library_outlined,
                    title: 'Choose from library',
                    subtitle: 'Select an existing image',
                    onTap: () async {
                      Navigator.pop(ctx);
                      await imageProv.pickImage(source: ImageSource.gallery);
                    },
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

class _PhotoAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBackground,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: kOutline),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: kAccentSurface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: kAccent, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryText,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.sp,
                          color: kSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14.sp, color: kSecondaryText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
