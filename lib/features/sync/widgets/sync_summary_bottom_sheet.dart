import 'package:fieldsync/features/sync/bloc/offline_sync_bloc.dart';
import 'package:fieldsync/features/sync/bloc/offline_sync_event.dart';
import 'package:fieldsync/features/sync/bloc/offline_sync_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/hive_setup.dart';
import '../../../core/config/themes/app_color.dart';
import '../../sync/models/offline_tree_survey.dart';

class SyncSummaryBottomSheet extends StatefulWidget {
  const SyncSummaryBottomSheet({super.key});

  @override
  State<SyncSummaryBottomSheet> createState() => _SyncSummaryBottomSheetState();
}

class _SyncSummaryBottomSheetState extends State<SyncSummaryBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Reset sync state when opening the bottom sheet to avoid showing old success state
    context.read<OfflineSyncBloc>().add(ResetSyncState());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflineSyncBloc, OfflineSyncState>(
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: HiveSetup.surveysBox.listenable(),
          builder: (context, box, _) {
            final surveys = box.values.toList();
            final total = surveys.length;
            final synced = surveys.where((s) => s.isSynced).length;
            final pending = total - synced;

            return Container(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(),
                    SizedBox(height: 20.h),
                    _buildHeader(pending),
                    SizedBox(height: 20.h),
                    _buildStats(total, synced, pending),
                    SizedBox(height: 20.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStateView(context, state, surveys),
                    ),
                    SizedBox(height: 24.h),
                    _buildActionButton(context, state, pending),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentStateView(
      BuildContext context, OfflineSyncState state, List<OfflineTreeSurvey> surveys) {
    if (state is OfflineSyncingData) {
      return _buildSyncProgress(state);
    } else if (state is OfflineSyncError) {
      return _buildErrorState(context, state.message);
    } else if (state is OfflineSyncCompleted) {
      return _buildSuccessState();
    } else {
      return _buildDailyBreakdown(surveys);
    }
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 48.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader(int pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Status',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          pending > 0
              ? '$pending items waiting to be uploaded.'
              : 'All your offline data is safely synced.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColor.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(int total, int synced, int pending) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primary.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Total', total.toString(), AppColor.textPrimary),
          Container(width: 1, height: 32.h, color: Colors.grey[300]),
          _buildStatItem('Synced', synced.toString(), Colors.green),
          Container(width: 1, height: 32.h, color: Colors.grey[300]),
          _buildStatItem('Pending', pending.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncProgress(OfflineSyncingData state) {
    final progress = state.total > 0 ? state.current / state.total : 0.0;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading...',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary),
              ),
              Text(
                '${state.current}/${state.total}',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: AppColor.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Colors.red[900],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<OfflineSyncBloc>().add(SyncOfflineData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 32.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Successful!',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900]),
                ),
                Text(
                  'All records uploaded.',
                  style: TextStyle(fontSize: 13.sp, color: Colors.green[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown(List<OfflineTreeSurvey> surveys) {
    final Map<String, List<OfflineTreeSurvey>> groupedSurveys = {};
    for (var survey in surveys) {
      final date = survey.surveyedAt ?? DateTime.now();
      final dateStr = DateFormat('MMM d, yyyy').format(date);
      groupedSurveys.putIfAbsent(dateStr, () => []).add(survey);
    }

    if (surveys.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Icon(Icons.cloud_done_outlined,
                  color: const Color(0xFFCBD5E1), size: 48.sp),
              SizedBox(height: 12.h),
              Text('No pending offline data',
                  style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary),
        ),
        SizedBox(height: 12.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 180.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: groupedSurveys.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final date = groupedSurveys.keys.elementAt(index);
              final items = groupedSurveys[date]!;
              final dateSynced = items.where((s) => s.isSynced).length;
              final isDone = dateSynced == items.length;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20.sp,
                      color: AppColor.primary.withOpacity(0.8),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: AppColor.textPrimary)),
                          SizedBox(height: 2.h),
                          Text('${items.length} records',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.textSecondary)),
                        ],
                      ),
                    ),
                    _buildStatusBadge(isDone, dateSynced, items.length),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isDone, int synced, int total) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 14.sp,
            color: isDone ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4.w),
          Text(
            isDone ? 'Synced' : '$synced/$total',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDone ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, OfflineSyncState state, int pending) {
    final bool isSyncing = state is OfflineSyncingData;
    final bool isCompleted = state is OfflineSyncCompleted;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSyncing
            ? null
            : (pending > 0
                ? () => context.read<OfflineSyncBloc>().add(SyncOfflineData())
                : () {
                    // Reset state on close to avoid showing success state next time
                    context.read<OfflineSyncBloc>().add(ResetSyncState());
                    Navigator.pop(context);
                  }),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.green : AppColor.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
          disabledBackgroundColor:
              isSyncing ? AppColor.primary.withOpacity(0.6) : const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
        ),
        child: isSyncing
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                isCompleted
                    ? 'Done'
                    : (pending > 0 ? 'Sync Now ($pending)' : 'Close'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
