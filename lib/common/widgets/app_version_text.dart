import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/config/themes/app_color.dart';
import '../../core/config/themes/app_fonts.dart';

class AppVersionText extends StatefulWidget {
  const AppVersionText({super.key});

  @override
  State<AppVersionText> createState() => _AppVersionTextState();
}

class _AppVersionTextState extends State<AppVersionText> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_version.isEmpty) return const SizedBox();

    return Text(
      _version,
      style: AppFonts.regular.copyWith(
        fontSize: 12.sp,
        color: AppColor.textMuted,
      ),
    );
  }
}
