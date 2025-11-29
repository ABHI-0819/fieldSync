import 'package:fieldsync/common/bloc/api_event.dart';
import 'package:fieldsync/common/repository/profile_repository.dart';
import 'package:fieldsync/features/authentication/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../core/config/resources/images.dart';
import '../../../core/config/route/app_route.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/network/api_connection.dart';
import '../bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/profile_response_model.dart';
import 'setting_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/Profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late ProfileBloc _profileBloc;

  @override
  void initState() {
    // 1. Initialize the ProfileBloc
    _profileBloc = ProfileBloc(
      ProfileRepository(api: ApiConnection()),
    );
    // 2. Dispatch the initial event to fetch profile data
    _profileBloc.add(ApiFetch());
    super.initState();
  }

  @override
  void dispose() {
    // Don't forget to close the bloc
    _profileBloc.close();
    super.dispose();
  }

  void _onLogoutTapped() {

  }

  @override
  Widget build(BuildContext context) {
    // Use BlocProvider to provide the ProfileBloc
    return BlocProvider<ProfileBloc>(
      create: (context) => _profileBloc,
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Use BlocConsumer for ProfileBloc
            child: BlocConsumer<ProfileBloc, ApiState<ProfileResponseModel, ResponseModel>>(
              listener: (context, state) async {
                // Handle loading and error states for profile fetching
                if (state is ApiLoading) {
                  EasyLoading.show(status: 'Loading Profile...');
                } else if (state is ApiSuccess<ProfileResponseModel, ResponseModel>) {
                  EasyLoading.dismiss();
                } else if (state is ApiFailure<ProfileResponseModel, ResponseModel>) {
                  EasyLoading.dismiss();
                  // Show error message

                } else if (state is TokenExpired) {
                  EasyLoading.dismiss();
                  // Handle token expiration: Navigate to Login Screen
                  AppRoute.pushReplacement(context, LoginScreen.route, arguments: {});
                }
              },
              builder: (context, state) {
                // Handle UI for different states
                if (state is ApiSuccess<ProfileResponseModel, ResponseModel>) {
                  // The data is available in state.data
                  final userProfileData = state.data.data;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColor.primary.withOpacity(0.1),
                            // Profile picture placeholder/actual image logic here
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // User Info Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ProfileTile(
                                icon: Images.nameIcon,
                                title: 'Name',
                                // Use fullName from the Profile model
                                subtitle: userProfileData.fullName,
                              ),
                              ProfileTile(
                                icon: Images.userTypeIcon,
                                title: 'User Role',
                                // Note: 'role' is in the User model, not Profile.
                                // Assuming you've adjusted your model structure or passed the role separately.
                                // Using a placeholder for now since the Profile model provided doesn't have 'group'/'role'.
                                // For a complete solution, you'd fetch the whole User object or augment the Profile model.
                                subtitle: 'Admin', // Placeholder for User Role
                              ),
                              const ProfileTile(
                                icon: Images.phoneIcon,
                                title: 'Phone Number',
                                subtitle: '+91 90878 27282', // Placeholder/Static data
                              ),
                              ProfileTile(
                                icon: Images.emailIcon,
                                title: 'Email ID',
                                // Email is typically in the User model, but we'll use a dummy field if needed
                                subtitle: userProfileData.email,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Subscription Status Card (Kept as is - uses mock data)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const SubscriptionStatusWidget(),
                        ),

                        const SizedBox(height: 20),
                        // Settings Section
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.secondary.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                Images.settingIcon,
                                width: 20,
                                height: 20,
                                color: AppColor.secondary,
                              ),
                            ),
                            title: Text(
                              'Settings',
                              style: AppFonts.small.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColor.secondary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColor.secondary.withOpacity(0.7),
                            ),
                            onTap: () {
                              AppRoute.goToNextPage(context: context, screen: SettingScreen.route,arguments: {});
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Logout Section
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.error.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                Images.logoutIcon,
                                width: 20,
                                height: 20,
                                color: AppColor.error,
                              ),
                            ),
                            title: Text(
                              'Logout',
                              style: AppFonts.small.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColor.error,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColor.error.withOpacity(0.7),
                            ),
                            onTap: _onLogoutTapped, // Call the new handler
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }

                // Handle ApiFailure (The generic error state)
                if (state is ApiFailure<ProfileResponseModel, ResponseModel>) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColor.error.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${state.error.message}",
                          style: AppFonts.small.copyWith(
                            color: AppColor.error,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Handle initial loading and any other states (e.g., TokenExpired which navigates)
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Retain the supporting widgets for context

class ProfileTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const ProfileTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppFonts.small.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            thickness: 0.5,
            color: AppColor.border,
            indent: 60,
            endIndent: 16,
          ),
      ],
    );
  }
}

class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({Key? key}) : super(key: key);

  // Mock data - replace with actual subscription data from your API
  bool get isSubscriptionActive => true; // This should come from your user data
  String get subscriptionPlan => "Premium Plan"; // This should come from your user data
  String get subscriptionExpiryDate => "Dec 31, 2024"; // This should come from your user data

  @override
  Widget build(BuildContext context) {
    // This widget's logic is unchanged from your original code
    final isSubscriptionActive = this.isSubscriptionActive; // Simplified local variable usage

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSubscriptionActive
                      ? AppColor.primary.withOpacity(0.1)
                      : AppColor.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSubscriptionActive ? Icons.verified : Icons.warning_amber,
                  color: isSubscriptionActive ? AppColor.primary : AppColor.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Status',
                      style: AppFonts.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSubscriptionActive ? 'Active' : 'Inactive',
                      style: AppFonts.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSubscriptionActive ? AppColor.success : AppColor.warning,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSubscriptionActive
                      ? AppColor.success.withOpacity(0.1)
                      : AppColor.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSubscriptionActive ? AppColor.success : AppColor.warning,
                    width: 1,
                  ),
                ),
                child: Text(
                  isSubscriptionActive ? 'ACTIVE' : 'EXPIRED',
                  style: AppFonts.small.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: isSubscriptionActive ? AppColor.success : AppColor.warning,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Subscription details
          if (isSubscriptionActive) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan:',
                        style: AppFonts.small.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      Text(
                        subscriptionPlan,
                        style: AppFonts.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expires on:',
                        style: AppFonts.small.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      Text(
                        subscriptionExpiryDate,
                        style: AppFonts.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ] else ...[
            // Inactive subscription UI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.warning.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColor.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your subscription has expired. Renew to continue using premium features.',
                      style: AppFonts.small.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Renew subscription button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to subscription purchase screen
                  // AppRoute.pushNamed(context, SubscriptionPlansScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Renew Subscription',
                  style: AppFonts.small.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}