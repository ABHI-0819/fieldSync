import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/storage/hive_setup.dart';
import '../../maps/screens/map_screen.dart';
import '../../survey/screens/tree_survey_form.dart';

@RoutePage()
class OfflineProjectsScreen extends StatelessWidget {
  static const route = '/offline-projects';

  const OfflineProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = HiveSetup.projectsBox.values.toList();

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Offline Projects',
          style: AppFonts.heading.copyWith(
            fontSize: 18.sp,
            color: Colors.black87,
          ),
        ),
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(
                    'No Offline Projects',
                    style: AppFonts.heading.copyWith(fontSize: 20.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "You haven't downloaded any projects for offline use.",
                    textAlign: TextAlign.center,
                    style: AppFonts.regular.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: projects.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final project = projects[index];
                return InkWell(
                  onTap: () {
                    // Navigate to Map Screen in Offline Mode to pick location
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(
                          projectId: project.id,
                          isOfflineMode: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.park_outlined, color: AppColor.primary),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: AppFonts.regular.copyWith(fontSize: 16.sp, color: Colors.black87),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                project.locationName,
                                style: AppFonts.regular.copyWith(fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
