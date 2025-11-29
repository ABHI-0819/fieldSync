import 'package:fieldsync/features/home/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:validators/validators.dart';

import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/login_repository.dart';
import '../../../core/config/constants/space.dart';
import '../../../core/config/route/app_route.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../../../core/network/api_connection.dart';
import '../../../core/storage/preference_keys.dart';
import '../../../core/storage/secure_storage.dart';
import '../bloc/auth_bloc.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class LoginScreen extends StatefulWidget {
  static const route = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AuthBloc _authBloc;
  TextEditingController? emailController;
  TextEditingController? passwordController;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final pref = SecurePreference();
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);

  @override
  void initState() {
    _authBloc = AuthBloc(
      LoginRepository(api: ApiConnection()),
    );
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _loadCredentials();

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    super.initState();
  }

  void _loadCredentials() async {
    String? email = await pref.getString(Keys.email);
    String? password =await pref.getString(Keys.password);

    if (email.isNotEmpty == true && password.isNotEmpty == true) {
      emailController!.text = email;
      passwordController!.text = password;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    emailController?.dispose();
    passwordController?.dispose();
    _authBloc.close();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => _authBloc,
      child: Scaffold(
          backgroundColor: AppColor.background,
          body:  BlocListener<AuthBloc, ApiState<LoginResponseModel,ResponseModel>>(
            listener: (context, state) {

              if (state is ApiSuccess<LoginResponseModel, ResponseModel>) {
                EasyLoading.dismiss();
                final userRole =state.data.data.user.role;
                if(userRole=='surveyor'){
                  AppRoute.goToNextPage(context: context, screen: MainScreen.route, arguments: {});
                }else{
                  IconSnackBar.show(
                    context,
                    snackBarType: SnackBarType.alert,
                    label: 'Invalid Credential',
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                  );
                }
              } else if (state is ApiFailure<LoginResponseModel, ResponseModel>) {
                EasyLoading.dismiss();
                IconSnackBar.show(
                  context,
                  snackBarType: SnackBarType.alert,
                  label: state.error.data.toString(),
                  backgroundColor: Colors.red,
                  iconColor: Colors.white,
                );
              } else if (state is TokenExpired<LoginResponseModel, ResponseModel>) {
                EasyLoading.dismiss();
                IconSnackBar.show(
                  context,
                  snackBarType: SnackBarType.alert,
                  label: state.error.data.toString(),
                  backgroundColor: Colors.red,
                  iconColor: Colors.white,
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                  child: Stack(
                    children: [
                      // Background decorative elements
                      _buildBackgroundDecoration(),

                      // Main content
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top spacer for visual breathing room
                                SizedBox(height: Spacing.xxLarge.h),

                                // Logo and header section
                                _buildHeaderSection(),
                                SizedBox(height: 20.h),
                                // Space before form
                                SizedBox(height: Spacing.large.h),

                                // Login form card
                                _buildLoginForm(),
                                // Push footer to bottom
                                // const Spacer(),
                                SizedBox(height: 60.h),
                                // Footer section
                                _buildFooter(),

                                // Bottom safe padding
                                SizedBox(height: 30.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        // Top curved background
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primary.withOpacity(0.1),
                  AppColor.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom curved background
        Positioned(
          bottom: -80,
          left: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.secondary.withOpacity(0.1),
                  AppColor.secondaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Floating dots
        Positioned(
          top: 150,
          left: 30,
          child: _buildFloatingDot(8, AppColor.primary.withOpacity(0.3)),
        ),
        Positioned(
          top: 200,
          right: 80,
          child: _buildFloatingDot(6, AppColor.secondary.withOpacity(0.4)),
        ),
        Positioned(
          bottom: 300,
          left: 50,
          child: _buildFloatingDot(10, AppColor.accent.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildFloatingDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo container with shadow
        Center(
          child: Image.network(
            'https://sikasolutions.in/images/sikalogo.png',
            width: 120,

          ),
        ),

        SizedBox(height: Spacing.medium.h),

        // Welcome text
        Text(
          'Welcome Back',
          style: AppFonts.heading.copyWith(
            color: AppColor.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: Spacing.small.h),

        Text(
          "Ready to survey more trees?",
          style: AppFonts.regular.copyWith(
            color: AppColor.textSecondary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(Spacing.medium.w!),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          _buildModernInputField(
            controller: emailController!,
            label: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),

          SizedBox(height: Spacing.medium.h),

          // Password field
          _buildModernInputField(
            controller: passwordController!,
            label: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            inputType: TextInputType.visiblePassword,
            isPassword: true,
          ),

          SizedBox(height: Spacing.small.h),

          // Remember me and forgot password
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: _rememberMe ? AppColor.primary : Colors.transparent,
                        border: Border.all(
                          color: _rememberMe ? AppColor.primary : AppColor.textMuted,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _rememberMe
                          ? Icon(
                        Icons.check,
                        size: 14.sp,
                        color: AppColor.white,
                      )
                          : null,
                    ),
                    SizedBox(width: Spacing.small.w),
                    Text(
                      'Remember me',
                      style: AppFonts.regular.copyWith(
                        color: AppColor.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: AppFonts.regular.copyWith(
                    color: AppColor.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Spacing.xLarge.h),

          // Login button
          _buildModernButton(),
        ],
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType inputType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.regular.copyWith(
            color: AppColor.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.small.h),
        Container(
          decoration: BoxDecoration(
            color: AppColor.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor.border,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            obscureText: isPassword && !_isPasswordVisible,
            style: AppFonts.regular.copyWith(
              color: AppColor.textPrimary,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppFonts.regular.copyWith(
                color: AppColor.textMuted,
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: AppColor.textMuted,
                size: 20.sp,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.textMuted,
                  size: 20.sp,
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r!),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:(){
            login(context: context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In',
                  style: AppFonts.regular.copyWith(
                    color: AppColor.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: Spacing.small.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColor.white,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColor.divider,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.medium.w!),
              child: Text(
                'Powered by SIKA',
                style: AppFonts.regular.copyWith(
                  color: AppColor.textMuted,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColor.divider,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.medium.h),
        Text(
          'Tree Survey Management System',
          style: AppFonts.regular.copyWith(
            color: AppColor.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void login({required BuildContext context}) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    final email = emailController?.text.trim() ?? '';
    final password = passwordController?.text.trim() ?? '';

    if (!isEmail(email)) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Please enter a valid email',
        backgroundColor: Colors.red,
        iconColor: Colors.white,
      );
    } else if (password.isEmpty) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: 'Password field is required',
        backgroundColor: Colors.red,
        iconColor: Colors.white,
      );
    } else {
      if (_rememberMe) {
        pref.setString(Keys.email, email);
        pref.setString(Keys.password, password);
      }
      final request = LoginRequestModel(
        email: email,
        password: password,
      );
      EasyLoading.show();
      _authBloc.add(ApiAdd(request));
    }
  }
}

// Optional: Enhanced custom painter (if you use it elsewhere)
class ModernBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColor.primary.withOpacity(0.05),
          AppColor.secondary.withOpacity(0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.8,
        size.width * 0.5,
        size.height * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}