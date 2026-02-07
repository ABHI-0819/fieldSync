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


class Project {
  final String id;
  final String pid;
  final String name;
  final String code;
  final String status;
  final String priority;
  final String organizationName;
  final String locationName;
  final String startDate;
  final String endDate;
  final int expectedTreeCount;
  final String daysRemaining;

  Project({
    required this.id,
    required this.pid,
    required this.name,
    required this.code,
    required this.status,
    required this.priority,
    required this.organizationName,
    required this.locationName,
    required this.startDate,
    required this.endDate,
    required this.expectedTreeCount,
    required this.daysRemaining,
  });

  // Mock data for demo
  static List<Project> mockData() => [
    Project(
      id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      pid: "PRJ-001",
      name: "Central Park Tree Survey",
      code: "CPTS-2024",
      status: "active",
      priority: "high",
      organizationName: "NYC Parks",
      locationName: "Central Park, Manhattan",
      startDate: "2024-01-15",
      endDate: "2024-06-30",
      expectedTreeCount: 1240,
      daysRemaining: "45 days",
    ),
    Project(
      id: "4fb96f75-6828-5673-c4gd-3d074g77bgb7",
      pid: "PRJ-002",
      name: "Brooklyn Bridge Green Belt",
      code: "BBGB-2024",
      status: "completed",
      priority: "medium",
      organizationName: "Brooklyn Parks Dept",
      locationName: "Brooklyn Bridge Area",
      startDate: "2023-11-10",
      endDate: "2024-03-01",
      expectedTreeCount: 872,
      daysRemaining: "Completed",
    ),
    Project(
      id: "5gc07g86-7939-6784-d5he-4e185h88chc8",
      pid: "PRJ-003",
      name: "Hudson Riverfront Restoration",
      code: "HRR-2024",
      status: "planning",
      priority: "low",
      organizationName: "Hudson River Trust",
      locationName: "Hudson Riverfront",
      startDate: "2024-02-20",
      endDate: "2024-12-15",
      expectedTreeCount: 2105,
      daysRemaining: "120 days",
    ),
  ];
}

// 👇 Semantic Spacing Constants
class Spacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
}

// 👇 Mock Search Bar
class CommonSearchBar extends StatelessWidget {
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onSubmitted;

  const CommonSearchBar({
    Key? key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.cardBackground,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColor.textMuted, size: 20.sp)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon, color: AppColor.primary, size: 20.sp),
          onPressed: onSuffixTap,
        )
            : null,
        hintText: hintText,
        hintStyle: AppFonts.regular.copyWith(
          fontSize: 14.sp,
          color: AppColor.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r!),
          borderSide: BorderSide(color: AppColor.border.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r!),
          borderSide: BorderSide(color: AppColor.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r!),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w!, vertical: 12.h!),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

// 👇 Filter Row Widget
class ProjectFilterRow extends StatelessWidget {
  final List<String> filterOptionList = ['All', 'Active', 'Planning', 'Completed'];
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  ProjectFilterRow({
    required this.selectedFilter,
    required this.onFilterChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptionList.length,
        separatorBuilder: (context, index) => SizedBox(width: Spacing.small.w),
        itemBuilder: (context, index) {
          final filter = filterOptionList[index];
          final isSelected = selectedFilter == filter;

          return Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColor.primary : AppColor.cardBackground,
              borderRadius: BorderRadius.circular(20.r!),
              border: Border.all(
                color: isSelected ? AppColor.primary : AppColor.border,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r!),
                onTap: () => onFilterChanged(filter),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w!, vertical: 8.h!),
                  child: Text(
                    filter,
                    style: AppFonts.regular.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColor.white : AppColor.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

@RoutePage()
class ProjectListScreen extends StatefulWidget {
  static const route = '/ProjectList';
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late ProjectListBloc _projectListBloc;
  String currentSearchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _projectListBloc = ProjectListBloc(
      ProjectRepository(),
    );
    _fetchProjects(search: '', filter: 'All');
  }

  @override
  void dispose() {
    _projectListBloc.close();
    super.dispose();
  }

  void _fetchProjects({required String search, required String filter}) {
    if(filter.toLowerCase()=='all'){
      _projectListBloc.add(
        ApiListFetch(
          page: 1,
          pageSize: 20,
        ),
      );
    }else{
      String statusFilter = filter.toLowerCase() == 'all' ? '' : filter.toLowerCase();
      _projectListBloc.add(
        ApiListFetch(
          search: search,
          filter: statusFilter,
          page: 1,
          pageSize: 20,
        ),
      );
    }
  }

  void _onSearch(String query) {
    setState(() {
      currentSearchQuery = query;
    });
    _fetchProjects(search: query, filter: _selectedFilter);
  }

  void _onFilterChanged(String selected) {
    setState(() {
      _selectedFilter = selected;
    });
    debugLog(selected,name: "Filter");
      _fetchProjects(search: currentSearchQuery, filter: selected);
  }

  void showVoiceSearchBottomSheet(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice search tapped")),
    );
  }

  // 🔁 Convert ProjectData → Project (UI model)
  Project _mapProjectDataToProject(ProjectData data) {
    String formattedDaysRemaining;
    if (data.status.toLowerCase() == 'completed') {
      formattedDaysRemaining = 'Completed';
    } else {
      formattedDaysRemaining = '${data.daysRemaining} days';
    }

    return Project(
      id: data.id,
      pid: data.pid,
      name: data.name,
      code: data.code,
      status: data.status,
      priority: data.priority,
      organizationName: data.organizationName,
      locationName: data.locationName,
      startDate: data.startDate.toIso8601String().split('T').first,
      endDate: data.endDate.toIso8601String().split('T').first,
      expectedTreeCount: data.expectedTreeCount,
      daysRemaining: formattedDaysRemaining,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _projectListBloc,
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: CustomScrollView(
          slivers: [
            // 👤 AppBar with Gradient Background
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColor.cardBackground,
              expandedHeight: 180.h,
              floating: true,
              snap: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: AppColor.background,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.medium.w,
                    vertical: Spacing.large.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Spacing.medium.h),
                      Text(
                        'Projects',
                        style: AppFonts.heading.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      SizedBox(height: Spacing.medium.h),
                      SizedBox(
                        height: 48.h,
                        child: CommonSearchBar(
                          labelText: 'Search',
                          hintText: 'Search by name or code...',
                          prefixIcon: Icons.search,
                          suffixIcon: Icons.mic,
                          onSuffixTap: () => showVoiceSearchBottomSheet(context),
                          onSubmitted: _onSearch,
                        ),
                      ),
                      SizedBox(height: Spacing.small.h),
                      ProjectFilterRow(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 📋 Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.medium.w,
                  vertical: Spacing.small.h,
                ),
                child: Text(
                  '${_selectedFilter} Projects',
                  style: AppFonts.regular.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // 📱 Project Cards or Loading/Empty State
            SliverToBoxAdapter(
              child: BlocConsumer<ProjectListBloc,
                  ApiState<ProjectListResponseModel, ResponseModel>>(
                listener: (context, state) {
                  if (state is ApiSuccess) {
                    EasyLoading.dismiss();
                  } else if (state is ApiFailure<ProjectListResponseModel, ResponseModel>) {
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
                  } else if (state is ApiSuccess<ProjectListResponseModel, ResponseModel>) {
                    final projectDataList = state.data.data ?? [];
                    if (projectDataList.isEmpty) {
                      return _buildEmptyState();
                    }

                    final List<Project> uiProjects = projectDataList
                        .map(_mapProjectDataToProject)
                        .toList();

                    return _buildProjectList(uiProjects);
                  } else {
                    return _buildEmptyState(); // handles ApiFailure, TokenExpired, etc.
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔽 The rest of your UI helpers (identical to your original)

  Widget _buildShimmerList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.medium.w!),
      child: Column(
        children: List.generate(3, (index) => _buildShimmerCard()),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.medium.h!),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r!),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList(List<Project> projects) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.medium.w!),
      child: Column(
        children: projects.map((project) => _buildProjectCard(project)).toList(),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (project.status.toLowerCase()) {
      case 'active':
        statusColor = AppColor.success;
        statusBgColor = AppColor.success.withOpacity(0.1);
        statusText = 'Active';
        break;
      case 'completed':
        statusColor = AppColor.textMuted;
        statusBgColor = AppColor.grey;
        statusText = 'Completed';
        break;
      case 'planning':
        statusColor = AppColor.accent;
        statusBgColor = AppColor.accentLight.withOpacity(0.2);
        statusText = 'Planning';
        break;
      default:
        statusColor = AppColor.textSecondary;
        statusBgColor = AppColor.grey;
        statusText = project.status;
    }

    Color priorityColor;
    switch (project.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppColor.error;
        break;
      case 'medium':
        priorityColor = AppColor.warning;
        break;
      default:
        priorityColor = AppColor.skyBlue;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.medium.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () {
            context.router.push(ProjectDetailRoute(projectId: project.id));
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(14.r!),
              border: Border.all(
                color: AppColor.border.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          project.code,
                          style: AppFonts.regular.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w!, vertical: 4.h!),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(6.r!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              statusText,
                              style: AppFonts.regular.copyWith(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    project.name,
                    style: AppFonts.regular.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: AppColor.textSecondary,
                      ),
                      SizedBox(width: 4.w),
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
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w!, vertical: 8.h!),
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8.r!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.park_outlined,
                                size: 16.sp,
                                color: AppColor.secondary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${project.expectedTreeCount}',
                                style: AppFonts.regular.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'trees',
                                style: AppFonts.regular.copyWith(
                                  fontSize: 11.sp,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w!, vertical: 8.h!),
                          decoration: BoxDecoration(
                            color: AppColor.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8.r!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 16.sp,
                                color: AppColor.accent,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  project.daysRemaining,
                                  style: AppFonts.regular.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.xLarge.w!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 60.sp,
              color: AppColor.textMuted,
            ),
            SizedBox(height: Spacing.medium.h),
            Text(
              'No projects found',
              style: AppFonts.regular.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: Spacing.small.h),
            Text(
              'Try changing your filter or search term.',
              textAlign: TextAlign.center,
              style: AppFonts.regular.copyWith(
                fontSize: 14.sp,
                color: AppColor.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
