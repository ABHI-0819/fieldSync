import 'package:fieldsync/core/config/route/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/config/resources/images.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../survey/screens/tree_survey_form.dart';
/*
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

 */


class HomeScreen extends StatefulWidget {
  static const route = '/surveyor-dashboard';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Survey Data
  final String surveyorName = "Surveyor";
  final int treesCount = 45;
  final int floraCount = 28;
  final int faunaCount = 16;
  final int todayCount = 12;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      // appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColor.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w!),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),

                  SizedBox(height: 24.h),

                  // Survey Categories
                  _buildSurveyCategoriesSection(),

                  SizedBox(height: 24.h),

                  // Today's Summary
                  _buildTodaysSummary(),

                  SizedBox(height: 24.h),

                  // Recent Surveys
                  _buildRecentSurveys(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.primary,
      elevation: 0,
      title: Text(
        'Survey Dashboard',
        style: AppFonts.heading.copyWith(
          color: AppColor.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _syncData,
          icon: Icon(
            Icons.sync,
            color: AppColor.white,
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: _showProfile,
          icon: Icon(
            Icons.account_circle,
            color: AppColor.white,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20.w!),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary.withOpacity(0.1), AppColor.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
              height: 50,
              width: 50,
              child: SvgPicture.asset(Images.profileFilledIcon)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $surveyorName',
                  style: AppFonts.heading.copyWith(
                    color: AppColor.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Ready to survey nature today?',
                  style: AppFonts.regular.copyWith(
                    color: AppColor.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Survey Categories',
          style: AppFonts.heading.copyWith(
            color: AppColor.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),

        // Tree Survey Card
        _buildSurveyCard(
          title: 'Trees',
          count: treesCount,
          icon: Icons.park,
          color: AppColor.primary,
          subtitle: 'Trees surveyed',
          onTap: () => _navigateToSurvey('tree'),
        ),

        // SizedBox(height: 12.h),
        //
        // // Flora Survey Card
        // _buildSurveyCard(
        //   title: 'Flora',
        //   count: floraCount,
        //   icon: Icons.local_florist,
        //   color: AppColor.secondary,
        //   subtitle: 'Plant species recorded',
        //   onTap: () => _navigateToSurvey('flora'),
        // ),

        SizedBox(height: 12.h),

        // Fauna Survey Card
        _buildSurveyCard(
          title: 'Fauna',
          count: faunaCount,
          icon: Icons.pets,
          color: AppColor.accent,
          subtitle: 'Animal species recorded',
          onTap: () => _navigateToSurvey('fauna'),
        ),
      ],
    );
  }

  Widget _buildSurveyCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w!),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12.r!),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r!),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.heading.copyWith(
                      color: AppColor.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppFonts.regular.copyWith(
                      color: AppColor.textMuted,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  count.toString(),
                  style: AppFonts.heading.copyWith(
                    color: color,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.textMuted,
                  size: 16.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: AppFonts.heading.copyWith(
            color: AppColor.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w!),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12.r!),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          todayCount.toString(),
                          style: AppFonts.heading.copyWith(
                            color: AppColor.primary,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Today\'s Surveys',
                      style: AppFonts.regular.copyWith(
                        color: AppColor.textSecondary,
                        fontSize: 12.sp,

                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60.h,
                color: AppColor.divider,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppColor.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${treesCount + floraCount + faunaCount}',
                          style: AppFonts.heading.copyWith(
                            color: AppColor.success,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Total Surveys',
                      style: AppFonts.regular.copyWith(
                        color: AppColor.textSecondary,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSurveys() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Surveys',
              style: AppFonts.heading.copyWith(
                color: AppColor.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _viewAllSurveys,
              child: Text(
                'View All',
                style: AppFonts.regular.copyWith(
                  color: AppColor.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Recent survey items
        _buildRecentSurveyItem(
          'Oak Tree',
          'Tree Survey',
          '2 hours ago',
          Icons.park,
          AppColor.primary,
        ),
        _buildRecentSurveyItem(
          'Rose Bush',
          'Flora Survey',
          '3 hours ago',
          Icons.local_florist,
          AppColor.secondary,
        ),
        _buildRecentSurveyItem(
          'Red Squirrel',
          'Fauna Survey',
          '5 hours ago',
          Icons.pets,
          AppColor.accent,
        ),
      ],
    );
  }

  Widget _buildRecentSurveyItem(String name, String type, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h!),
      padding: EdgeInsets.all(12.w!),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8.r!),
        border: Border.all(
          color: AppColor.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6.r!),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppFonts.regular.copyWith(
                    color: AppColor.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  type,
                  style: AppFonts.regular.copyWith(
                    color: AppColor.textMuted,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppFonts.regular.copyWith(
              color: AppColor.textMuted,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showSurveyOptions,
      backgroundColor: AppColor.primary,
      child: Icon(
        Icons.add,
        color: AppColor.white,
        size: 28.sp,
      ),
    );
  }

  // Action Methods
  void _navigateToSurvey(String type) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to specific survey type (tree, flora, fauna)
    AppRoute.goToNextPage(context: context, screen: TreeSurveyFormScreen.route, arguments: {
      'projectId':'jdfhsdkfkdshf',
      'latitude':17.3734324,
      'longitude':74.3248723
      /*
               projectId: argument!['projectId'],
            latitude :argument['latitude'],
            longitude: argument['longitude'],
        */

    });
  }

  void _showSurveyOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r!)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w!),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Start New Survey',
              style: AppFonts.heading.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSurveyOption('Tree Survey', Icons.park, AppColor.primary, 'tree'),
            _buildSurveyOption('Flora Survey', Icons.local_florist, AppColor.secondary, 'flora'),
            _buildSurveyOption('Fauna Survey', Icons.pets, AppColor.accent, 'fauna'),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyOption(String title, IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateToSurvey(type);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h!),
        padding: EdgeInsets.all(16.w!),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r!),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppFonts.regular.copyWith(
                color: AppColor.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _syncData() async {
    HapticFeedback.lightImpact();
    EasyLoading.show(status: 'Syncing...');
    await Future.delayed(const Duration(seconds: 2));
    EasyLoading.showSuccess('Data synced!');
  }

  void _showProfile() {
    HapticFeedback.lightImpact();
    // TODO: Show profile screen
  }

  void _viewAllSurveys() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to all surveys list
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data
    });
  }
}
