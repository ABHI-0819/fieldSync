import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/common/bloc/api_event.dart';
import 'package:fieldsync/common/repository/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/models/success_response_model.dart';
import '../../../common/repository/login_repository.dart';
import '../../../core/config/resources/images.dart';
import '../../../core/config/route/app_route.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/storage/preference_keys.dart';
import '../../../core/storage/secure_storage.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import '../models/profile_response_model.dart';

// Retain the supporting widgets for context
class ProfileScreen extends StatefulWidget {
  static const route = '/Profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SecurePreference _securePref = SecurePreference();

  late final ProfileBloc _profileBloc;
  late final LogoutBloc _logoutBloc;

  @override
  void initState() {
    super.initState();

    _profileBloc = ProfileBloc(
      ProfileRepository(),
    )..add(ApiFetch());

    _logoutBloc = LogoutBloc(LoginRepository());
  }

  @override
  void dispose() {
    _profileBloc.close();
    _logoutBloc.close();
    super.dispose();
  }

  void _onLogoutTapped() async {
    final refreshToken =
        await _securePref.getString(Keys.refreshToken);

    _logoutBloc.add(ApiLogout(refreshToken));
  }

  void _logoutListener(
    BuildContext context,
    ApiState<SuccessResponseModel, ResponseModel> state,
  ) async {
    if (state is ApiLoading<SuccessResponseModel, ResponseModel>) {
      EasyLoading.show(status: 'Logging out...');
    }

    if (state is ApiSuccess<SuccessResponseModel, ResponseModel>) {
      EasyLoading.dismiss();
      await _securePref.clear();
      context.router.replaceAll([const LoginRoute()]);
    }

    if (state is ApiFailure<SuccessResponseModel, ResponseModel>) {
      EasyLoading.dismiss();
      EasyLoading.showError(state.error.message??'Logout Failed.');
    }

    if (state is TokenExpired<SuccessResponseModel, ResponseModel>) {
      EasyLoading.dismiss();
      await _securePref.clear();
      context.router.replaceAll([const LoginRoute()]);
      // AppRoute.pushReplacement(
      //   context,
      //   LoginScreen.route,
      //   arguments: {},
      // );
    }
  }

  void _profileListener(
    BuildContext context,
    ApiState<ProfileResponseModel, ResponseModel> state,
  ) {
    if (state is TokenExpired) {
      EasyLoading.dismiss();
      _securePref.clear();
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
        BlocProvider<LogoutBloc>.value(value: _logoutBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LogoutBloc,
              ApiState<SuccessResponseModel, ResponseModel>>(
            listener: _logoutListener,
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocConsumer<ProfileBloc,
                  ApiState<ProfileResponseModel, ResponseModel>>(
                listener: _profileListener,
                builder: (context, state) {
                  if (state is ApiSuccess<ProfileResponseModel, ResponseModel>) {
                    final user = state.data.data;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          /// Profile Avatar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    AppColor.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  AppColor.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColor.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// Profile Info
                          _infoCard(
                            children: [
                              ProfileTile(
                                icon: Images.nameIcon,
                                title: 'Name',
                                subtitle: user.fullName,
                              ),
                              ProfileTile(
                                icon: Images.userTypeIcon,
                                title: 'User Role',
                                subtitle: 'Surveyor',
                              ),
                              const ProfileTile(
                                icon: Images.phoneIcon,
                                title: 'Phone Number',
                                subtitle: '+91 XXXXX XXXXX',
                              ),
                              ProfileTile(
                                icon: Images.emailIcon,
                                title: 'Email ID',
                                subtitle: user.email,
                                isLast: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Subscription
                          _infoCard(
                            children: const [
                              SubscriptionStatusWidget(),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Settings
                          _actionTile(
                            icon: Images.settingIcon,
                            color: AppColor.secondary,
                            title: 'Settings',
                            onTap: () {
                              // AppRoute.goToNextPage(
                              //   context: context,
                              //   screen: SettingScreen.route,
                              //   arguments: {},
                              // );
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Logout
                          _actionTile(
                            icon: Images.logoutIcon,
                            color: AppColor.error,
                            title: 'Logout',
                            onTap: _onLogoutTapped,
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildShimmerLoading();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }


  ///Simmer Widgets
  Widget _buildShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: SingleChildScrollView(
      child: Column(
        children: [
          // Profile Avatar Shimmer
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Profile Info Card Shimmer
          _shimmerInfoCard(),
          const SizedBox(height: 20),
          
          // Subscription Card Shimmer
          _shimmerInfoCard(height: 80),
          const SizedBox(height: 20),
          
          // Settings Tile Shimmer
          _shimmerActionTile(),
          const SizedBox(height: 20),
          
          // Logout Tile Shimmer  
          _shimmerActionTile(),
        ],
      ),
    ),
  );
}

Widget _buildProfileContent() {
  return Column(
    children: [
      // Your existing profile avatar
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.primary.withOpacity(0.3), width: 2),
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: AppColor.primary.withOpacity(0.1),
          child: Icon(Icons.person, size: 50, color: AppColor.primary),
        ),
      ),
      // ... rest of your existing content
    ],
  );
}

Widget _shimmerInfoCard({double height = 200}) {
  return Container(
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(4, (index) => _shimmerTile()),
      ),
    ),
  );
}

Widget _shimmerTile() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(width: 24, height: 24, color: Colors.white),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 80, height: 12, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: 120, height: 12, color: Colors.white),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _shimmerActionTile() {
  return Container(
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 24, height: 24, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 16, color: Colors.white)),
        ],
      ),
    ),
  );
}

  /// =========================
  /// UI HELPERS
  /// =========================


  Widget _infoCard({required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _actionTile({
    required String icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: AppFonts.small.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color.withOpacity(0.7),
        ),
        onTap: onTap,
      ),
    );
  }
}

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
  String get subscriptionPlan =>
      "Premium Plan"; // This should come from your user data
  String get subscriptionExpiryDate =>
      "Dec 30, 2026"; // This should come from your user data

  @override
  Widget build(BuildContext context) {
    // This widget's logic is unchanged from your original code
    final isSubscriptionActive =
        this.isSubscriptionActive; // Simplified local variable usage

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
                  color: isSubscriptionActive
                      ? AppColor.primary
                      : AppColor.warning,
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
                        color: isSubscriptionActive
                            ? AppColor.success
                            : AppColor.warning,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSubscriptionActive
                      ? AppColor.success.withOpacity(0.1)
                      : AppColor.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSubscriptionActive
                        ? AppColor.success
                        : AppColor.warning,
                    width: 1,
                  ),
                ),
                child: Text(
                  isSubscriptionActive ? 'ACTIVE' : 'EXPIRED',
                  style: AppFonts.small.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: isSubscriptionActive
                        ? AppColor.success
                        : AppColor.warning,
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
