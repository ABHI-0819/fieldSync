import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../bloc/offline_sync_bloc.dart';
import '../bloc/offline_sync_event.dart';
import '../bloc/offline_sync_state.dart';
import '../../../common/repository/project_repository.dart';
import '../../../common/repository/tree_repository.dart';

@RoutePage()
class ResourceSyncScreen extends StatefulWidget {
  final String projectId;
  static const route = '/resource-sync';

  const ResourceSyncScreen({super.key, required this.projectId});

  @override
  State<ResourceSyncScreen> createState() => _ResourceSyncScreenState();
}

class _ResourceSyncScreenState extends State<ResourceSyncScreen> {
  late OfflineSyncBloc _offlineSyncBloc;

  @override
  void initState() {
    super.initState();
    _offlineSyncBloc = OfflineSyncBloc(
      ProjectRepository(),
      TreeRepository(),
    );
    _offlineSyncBloc.add(DownloadResources(projectId: widget.projectId));
  }

  @override
  void dispose() {
    _offlineSyncBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blueish background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20.sp),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocProvider.value(
          value: _offlineSyncBloc,
          child: BlocBuilder<OfflineSyncBloc, OfflineSyncState>(
            builder: (context, state) {
              double overallProgress = 0.0;
              bool isComplete = false;

              Map<String, SyncTaskStatus> taskStatuses = {
                'project': SyncTaskStatus.pending,
                'species': SyncTaskStatus.pending,
                'baseLayer': SyncTaskStatus.pending,
              };

              Map<String, double> taskProgresses = {
                'project': 0.0,
                'species': 0.0,
                'baseLayer': 0.0,
              };

              if (state is OfflineSyncDownloading) {
                overallProgress = state.overallProgress;
                taskStatuses = state.taskStatuses;
                taskProgresses = state.taskProgresses;
              } else if (state is OfflineSyncReady) {
                overallProgress = 1.0;
                isComplete = true;
                taskStatuses = {
                  'project': SyncTaskStatus.downloaded,
                  'species': SyncTaskStatus.downloaded,
                  'baseLayer': SyncTaskStatus.downloaded,
                };
                taskProgresses = {
                  'project': 1.0,
                  'species': 1.0,
                  'baseLayer': 1.0,
                };
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopCard(overallProgress),
                          SizedBox(height: 24.h),
                          Text(
                            'ACTIVE TASKS',
                            style: AppFonts.regular.copyWith(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildTaskItem(
                            title: 'Project Details',
                            status: taskStatuses['project']!,
                            progress: taskProgresses['project']!,
                            icon: Icons.assignment_outlined,
                          ),
                          SizedBox(height: 12.h),
                          _buildTaskItem(
                            title: 'Tree Species List',
                            status: taskStatuses['species']!,
                            progress: taskProgresses['species'] ?? 0.0,
                            icon: Icons.sync_rounded,
                          ),
                          SizedBox(height: 12.h),
                          _buildTaskItem(
                            title: 'Base Layer',
                            status: taskStatuses['baseLayer']!,
                            progress: taskProgresses['baseLayer'] ?? 0.0,
                            icon: Icons.map_outlined,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(context, isComplete),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(double overallProgress) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            height: 64.w,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: overallProgress,
                  strokeWidth: 6.w,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColor.primary, // Dark blue
                  ),
                ),
                Center(
                  child: Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: AppFonts.heading.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preparing Offline Data',
                  style: AppFonts.heading.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Downloading necessary files for offline use. Please wait...',
                  style: AppFonts.regular.copyWith(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required SyncTaskStatus status,
    required double progress,
    required IconData icon,
  }) {
    Color iconColor;
    Color iconBgColor;
    Color textColor;
    String statusText;
    bool showProgress = false;

    switch (status) {
      case SyncTaskStatus.pending:
        iconColor = const Color(0xFF64748B);
        iconBgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF94A3B8);
        statusText = 'Pending';
        icon = Icons.access_time_rounded;
        break;
      case SyncTaskStatus.downloading:
        iconColor = const Color(0xFF2563EB);
        iconBgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        statusText = 'Downloading...';
        showProgress = true;
        icon = Icons.sync_rounded;
        break;
      case SyncTaskStatus.downloaded:
        iconColor = const Color(0xFF16A34A);
        iconBgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        statusText = 'Downloaded';
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppFonts.regular.copyWith(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (showProgress)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppFonts.regular.copyWith(
                          fontSize: 12.sp,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (status == SyncTaskStatus.downloaded)
                      Icon(Icons.chevron_right,
                          color: const Color(0xFFCBD5E1), size: 20.sp),
                    if (status == SyncTaskStatus.pending)
                      Icon(Icons.pause,
                          color: const Color(0xFFCBD5E1), size: 16.sp),
                  ],
                ),
                SizedBox(height: 4.h),
                if (showProgress) ...[
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(const Color(0xFF1E3A8A)),
                    minHeight: 4.h,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  SizedBox(height: 6.h),
                ],
                Text(
                  statusText,
                  style: AppFonts.regular.copyWith(
                    fontSize: 12.sp,
                    color: textColor,
                    fontStyle:
                        showProgress ? FontStyle.italic : FontStyle.normal,
                    fontWeight:
                        showProgress ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isComplete) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: isComplete ? () => Navigator.pop(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? AppColor.primary : AppColor.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: AppFonts.regular.copyWith(
                    color: isComplete ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward,
                  color: isComplete ? Colors.white : const Color(0xFF94A3B8),
                  size: 18.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Complete all downloads to proceed',
            style: AppFonts.regular.copyWith(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
