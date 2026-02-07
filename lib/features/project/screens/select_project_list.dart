import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/project_repository.dart';
import '../../../core/config/route/app_route.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../bloc/project_bloc.dart';
import '../models/project_list_respone_model.dart';

@RoutePage()
class SelectProjectScreen extends StatefulWidget {
  static const route = '/select-project';

  const SelectProjectScreen({Key? key}) : super(key: key);

  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  late ProjectListBloc _projectListBloc;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _projectListBloc = ProjectListBloc(ProjectRepository());
    _fetchProjects();
  }

  @override
  void dispose() {
    _projectListBloc.close();
    super.dispose();
  }

  void _fetchProjects() {
    _projectListBloc.add(ApiListFetch(page: 1, pageSize: 20));
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _projectListBloc.add(ApiListFetch(search: query, page: 1, pageSize: 20));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _projectListBloc,
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).canPop()
                              ? Navigator.of(context).pop()
                              : null,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.grey.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Expanded(
                      child: Center(
                        child: Text(
                          'Select Your Project',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            10.verticalSpace,
            Container(
              // color: AppColor.cardBackground,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 5.h),
              child: TextField(
                onChanged: _onSearch,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColor.white,
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.textMuted, size: 20.sp),
                  hintText: 'Search projects...',
                  hintStyle: AppFonts.regular.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),

            // Project List
            Expanded(
              child: BlocConsumer<ProjectListBloc,
                  ApiState<ProjectListResponseModel, ResponseModel>>(
                listener: (context, state) {
                  if (state is ApiSuccess) {
                    EasyLoading.dismiss();
                  } else if (state
                      is ApiFailure<ProjectListResponseModel, ResponseModel>) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error.data.toString())),
                    );
                  } else if (state is TokenExpired) {
                    EasyLoading.dismiss();
                    context.router.replaceAll([const LoginRoute()]);
                  }
                },
                builder: (context, state) {
                  if (state is ApiLoading) {
                    return _buildShimmerList();
                  } else if (state
                      is ApiSuccess<ProjectListResponseModel, ResponseModel>) {
                    final projects = state.data.data ?? [];
                    if (projects.isEmpty) return _buildEmptyState();
                    return _buildProjectList(projects);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 60.h, // Compact shimmer height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList(List<ProjectData> projects) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: projects.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, index) => _buildProjectCard(projects[index]),
    );
  }

  /*
  Widget _buildProjectCard(ProjectData project) {
    Color statusColor = _getStatusColor(project.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => context.router.push(MapRoute(projectId: project.id)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1: Project Name + Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: AppFonts.regular.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      project.status.toUpperCase(),
                      style: AppFonts.regular.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Line 2: Location + Tree Count
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.locationName,
                      style: AppFonts.regular.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.park_outlined,
                      size: 13.sp, color: AppColor.secondary),
                  SizedBox(width: 3.w),
                  Text(
                    '${project.expectedTreeCount}',
                    style: AppFonts.regular.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  */
  Widget _buildProjectCard(ProjectData project) {
    Color statusColor = _getStatusColor(project.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => context.router.push(MapRoute(projectId: project.id)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Left: Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.folder_outlined,
                  size: 20.sp,
                  color: AppColor.primary,
                ),
              ),

              SizedBox(width: 12.w),

              // Middle: Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: Project Name
                    Text(
                      project.name,
                      style: AppFonts.regular.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Line 2: Location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12.sp, color: AppColor.textMuted),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            project.locationName,
                            style: AppFonts.regular.copyWith(
                              fontSize: 11.sp,
                              color: AppColor.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Right: Status Badge + Arrow
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      project.status,
                      style: AppFonts.regular.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    Icons.chevron_right,
                    size: 18.sp,
                    color: AppColor.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'planning':
        return const Color(0xFFF59E0B);
      default:
        return AppColor.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined,
              size: 60.sp, color: AppColor.textMuted),
          SizedBox(height: 16.h),
          Text(
            'No projects found',
            style: AppFonts.regular.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different search term',
            style: AppFonts.regular.copyWith(
              fontSize: 14.sp,
              color: AppColor.textMuted,
            ),
          ),
        ],
      ),
    );
  }
  /*
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColor.success;
      case 'completed':
        return AppColor.textMuted;
      case 'planning':
        return AppColor.accent;
      default:
        return AppColor.textSecondary;
    }
  }
  */
}
