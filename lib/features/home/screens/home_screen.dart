import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/core/config/route/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/widgets/SecureText.dart';
import '../../../core/config/resources/images.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/storage/preference_keys.dart';
import '../../survey/screens/tree_survey_form.dart';

/*
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
      backgroundColor: AppColor.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting Section
              _buildGreetingSection(),
              const SizedBox(height: 32),
              // Statistics Overview
              _buildStatisticsSection(),
              const SizedBox(height: 32),
              // Primary Actions
              _buildPrimaryActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: const TextStyle(
            fontSize: 16,
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Abhishek',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to make a difference today?',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              icon: Icons.park_outlined,
              count: '1,234',
              label: 'Trees',
              color: AppColor.secondary,
            ),
            _buildStatCard(
              icon: Icons.pets_outlined,
              count: '856',
              label: 'Fauna',
              color: AppColor.primary,
            ),
            _buildStatCard(
              icon: Icons.folder_outlined,
              count: '42',
              label: 'Projects',
              color: AppColor.skyBlue,
            ),
          ],
        ),
      ],
    );
  }

 Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.assignment_outlined,
          label: 'Start Survey',
          subtitle: 'Begin a new environmental survey',
          onTap: () {},
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.cloud_off_outlined,
          label: 'Start Offline Survey',
          subtitle: 'Survey without internet connection',
          onTap: () {},
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColor.primary : AppColor.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: AppColor.border, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColor.white.withOpacity(0.15)
                    : AppColor.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppColor.white : AppColor.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary
                          ? AppColor.white
                          : AppColor.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isPrimary
                          ? AppColor.white.withOpacity(0.85)
                          : AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary
                  ? AppColor.white.withOpacity(0.9)
                  : AppColor.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: AppColor.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                 const SizedBox(height: 20),
              _buildGreetingSection(),
              const SizedBox(height: 20),
                 const Text(
          'Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
              const SizedBox(height: 12),
              _buildStatisticsSection(),
              const SizedBox(height: 20),
              _buildPrimaryActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
           decoration: BoxDecoration(
                    color: AppColor.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.border.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12 ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                   SecureText(
                      prefKey: Keys.name,
                      defaultValue: 'User',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                        letterSpacing: -0.8,
                        height: 1.2,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColor.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatCard(
          icon: Icons.park_outlined,
          count: '1',
          label: 'Total Trees',
          color: AppColor.secondary,
        ),
        // const SizedBox(height: 10),
        _buildStatCard(
          icon: Icons.pets_outlined,
          count: '0',
          label: 'Total Fauna',
          color: AppColor.primary,
        ),
        // const SizedBox(height: 10),
        _buildStatCard(
          icon: Icons.folder_outlined,
          count: '1',
          label: 'Projects',
          color: AppColor.skyBlue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 0.44.sw,
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.add_circle_outline,
          label: 'Start Survey',
          subtitle: 'Begin new survey',
          onTap: () {
              context.router.push(ProjectListRoute());
          },
          color: AppColor.primary,
          isGradient: true,
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: Icons.cloud_off_outlined,
          label: 'Offline Survey',
          subtitle: 'Survey without internet',
          onTap: () {
            context.router.push(UnderDevelopmentRoute(
              featureName: 'Offline Survey',
              message:
                  'This feature is under development. Stay tuned for updates!',
            ));
          },
          color: AppColor.cardBackground,
          isGradient: false,
        ),

      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required bool isGradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isGradient
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isGradient ? null : AppColor.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isGradient
              ? null
              : Border.all(color: AppColor.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: isGradient
                  ? color.withOpacity(0.2)
                  : AppColor.black.withOpacity(0.03),
              blurRadius: isGradient ? 10 : 6,
              offset: Offset(0, isGradient ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isGradient
                    ? AppColor.white.withOpacity(0.2)
                    : AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isGradient ? AppColor.white : AppColor.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isGradient
                          ? AppColor.white
                          : AppColor.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isGradient
                          ? AppColor.white.withOpacity(0.85)
                          : AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isGradient
                  ? AppColor.white.withOpacity(0.9)
                  : AppColor.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


}