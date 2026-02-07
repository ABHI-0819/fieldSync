import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/features/authentication/screens/login_screen.dart';
import 'package:fieldsync/features/maps/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/models/success_response_model.dart';
import '../../../common/repository/tree_repository.dart';
import '../../../core/config/constants/space.dart';
import '../../../core/config/route/app_route.dart';
import '../../../core/config/themes/app_color.dart';
import '../../../core/config/themes/app_fonts.dart';
import '../bloc/tree_species_bloc.dart';
import '../bloc/tree_survey_bloc.dart';
import '../models/tree_request_model.dart';
import '../models/tree_species_response_model.dart';

// Models
class TreeSpecies {
  final String id;
  final String name;
  final String scientificName;

  TreeSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
  });
}

// Main Form Screen
@RoutePage()
class TreeSurveyFormScreen extends StatefulWidget {
  final String projectId;
  final double latitude;
  final double longitude;
  static const route = '/TreeSurveyForm';

  const TreeSurveyFormScreen({
    super.key,
    required this.projectId,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<TreeSurveyFormScreen> createState() => _TreeSurveyFormScreenState();
}

class _TreeSurveyFormScreenState extends State<TreeSurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for required fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _girthController = TextEditingController();

  // Controllers for additional fields
  final TextEditingController _ownershipController = TextEditingController();
  final TextEditingController _canopyDiameterController =
      TextEditingController();
  final TextEditingController _estimatedAgeController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _threatsController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _fieldOfficerController = TextEditingController();

  // Selected values
  String? _selectedProjectId;
  TreeSpecies? _selectedSpecies;
  String? _selectedHealthStatus;
  String? _selectedSiteQuality;
  String? _selectedDamageSeverity;

  // Additional details toggle
  bool _showAdditionalDetails = false;

  // Images
  List<File> _selectedImages = [];

  late TreeSurveyBloc _treeSurveyBloc;

  @override
  void initState() {
    super.initState();
    _treeSurveyBloc = TreeSurveyBloc(
      TreeRepository(),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _girthController.dispose();
    _ownershipController.dispose();
    _canopyDiameterController.dispose();
    _estimatedAgeController.dispose();
    _soilTypeController.dispose();
    _threatsController.dispose();
    _remarkController.dispose();
    _fieldOfficerController.dispose();
    _treeSurveyBloc.close();
    super.dispose();
  }

  void _showSpeciesSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpeciesSearchBottomSheet(
        onSpeciesSelected: (species) {
          setState(() {
            _selectedSpecies = species;
          });
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecies == null) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please select the tree species',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if (_heightController.text.isEmpty) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please enter the height',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if (_girthController.text.isEmpty) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please enter the girth',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if (_selectedHealthStatus == null) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please select health status',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if (_selectedImages.isEmpty) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please upload at least one image',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }

      final request = TreeSurveyRequest(
        project: widget.projectId,
        species: _selectedSpecies!.id,
        location: {
          "type": "Point",
          "coordinates": [widget.longitude, widget.latitude],
        },
        ownership: _ownershipController.text.trim(),
        height: _heightController.text.trim(),
        girth: _girthController.text.trim(),
        canopyDiameter: _canopyDiameterController.text.trim(),
        estimatedAge: int.tryParse(_estimatedAgeController.text.trim()),
        healthStatus: _selectedHealthStatus!,
        soilType: _soilTypeController.text.trim(),
        siteQuality: _selectedSiteQuality,
        threats: _threatsController.text.trim(),
        damageSeverity: _selectedDamageSeverity,
        images: _selectedImages,
        remark: _remarkController.text.trim(),
        fieldOfficer: _fieldOfficerController.text.trim(),
      );
      _treeSurveyBloc.add(
        AddTreeSurvey(
          request: request,
          images: _selectedImages,
        ),
      );
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        'Tree Survey',
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
      body: BlocProvider(
        create: (context) => _treeSurveyBloc,
        child: BlocListener<TreeSurveyBloc,
            ApiState<SuccessResponseModel, ResponseModel>>(
          listener: (context, state) {
            if (state is ApiLoading) {
              EasyLoading.show(status: 'Submitting...');
            } else if (state
                is ApiSuccess<SuccessResponseModel, ResponseModel>) {
              EasyLoading.dismiss();
              IconSnackBar.show(
                context,
                snackBarType: SnackBarType.success,
                label: state.data.message,
                backgroundColor: Colors.green,
                iconColor: Colors.white,
              );
               context.router.pop(widget.projectId);
              // success
            } else if (state
                is ApiFailure<SuccessResponseModel, ResponseModel>) {
              EasyLoading.dismiss();
              IconSnackBar.show(
                context,
                snackBarType: SnackBarType.alert,
                label: state.error.data.toString(),
                backgroundColor: Colors.red,
                iconColor: Colors.white,
              );
            } else if (state is TokenExpired) {
              EasyLoading.dismiss();
              context.router.replaceAll([const LoginRoute()]);
              // AppRoute.pushReplacement(context, LoginScreen.route, arguments: {});
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Required Fields Section
                        _buildSectionHeader('Basic Information',
                            isRequired: true),
                        SizedBox(height: 12.h),

                        // Species Selection
                        _buildSpeciesSelector(),
                        SizedBox(height: 16.h),

                        // Location
                        _buildLocationField(),
                        SizedBox(height: 16.h),

                        // Height
                        _buildTextField(
                          controller: _heightController,
                          label: 'Height (meters)',
                          hint: 'e.g., 15.5',
                          isRequired: true,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          suffixText: 'm',
                        ),
                        SizedBox(height: 16.h),

                        // Girth
                        _buildTextField(
                          controller: _girthController,
                          label: 'Girth at Breast Height (meters)',
                          hint: 'e.g., 1.2',
                          isRequired: true,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          suffixText: 'm',
                        ),
                        SizedBox(height: 16.h),

                        // Health Status
                        _buildHealthStatusSelector(),
                        SizedBox(height: 16.h),

                        // Images
                        _buildImageSelector(),
                        SizedBox(height: 24.h),

                        // Additional Details Toggle Button
                        _buildAdditionalDetailsButton(),
                        SizedBox(height: 16.h),

                        // Additional Details Section (Collapsible)
                        if (_showAdditionalDetails) ...[
                          _buildSectionHeader('Additional Details',
                              isRequired: false),
                          SizedBox(height: 12.h),
                          _buildTextField(
                            controller: _ownershipController,
                            label: 'Ownership',
                            hint: 'e.g., Public, Private',
                            isRequired: false,
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _canopyDiameterController,
                            label: 'Canopy Diameter (meters)',
                            hint: 'e.g., 8.5',
                            isRequired: false,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            suffixText: 'm',
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _estimatedAgeController,
                            label: 'Estimated Age (years)',
                            hint: 'e.g., 50',
                            isRequired: false,
                            keyboardType: TextInputType.number,
                            suffixText: 'yrs',
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _soilTypeController,
                            label: 'Soil Type',
                            hint: 'e.g., Loamy, Clay',
                            isRequired: false,
                          ),
                          SizedBox(height: 16.h),
                          _buildSiteQualitySelector(),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _threatsController,
                            label: 'Threats',
                            hint: 'e.g., Pest infestation, Construction',
                            isRequired: false,
                            maxLines: 2,
                          ),
                          SizedBox(height: 16.h),
                          _buildDamageSeveritySelector(),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _remarkController,
                            label: 'Remarks',
                            hint: 'Any additional notes...',
                            isRequired: false,
                            maxLines: 3,
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _fieldOfficerController,
                            label: 'Field Officer',
                            hint: 'Officer name',
                            isRequired: false,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ],
                    ),
                  ),
                ),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isRequired}) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        if (isRequired) ...[
          SizedBox(width: 4.w),
          Text(
            '*',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isRequired,
    TextInputType? keyboardType,
    String? suffixText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColor.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textMuted,
            ),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColor.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.error),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSpeciesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Species',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _showSpeciesSearchDialog,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.border),
            ),
            child: Row(
              children: [
                Icon(Icons.park_outlined,
                    color: AppColor.secondary, size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: _selectedSpecies == null
                      ? Text(
                          'Search and select species',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColor.textMuted,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSpecies!.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedSpecies!.scientificName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColor.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                ),
                Icon(Icons.search, color: AppColor.primary, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: AppColor.accent, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.latitude.toStringAsFixed(6)}°, ${widget.longitude.toStringAsFixed(6)}°',
                      style: AppFonts.regular.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildHealthStatusSelector() {
    final healthOptions = [
      {'value': 'excellent', 'label': 'Excellent', 'color': AppColor.success},
      {'value': 'good', 'label': 'Good', 'color': AppColor.secondary},
      {'value': 'fair', 'label': 'Fair', 'color': AppColor.warning},
      {'value': 'poor', 'label': 'Poor', 'color': AppColor.accent},
      {'value': 'dying', 'label': 'Dying', 'color': AppColor.error},
      {'value': 'dead', 'label': 'Dead', 'color': AppColor.textMuted},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Health Status',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: healthOptions.map((option) {
            final isSelected = _selectedHealthStatus == option['value'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedHealthStatus = option['value'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (option['color'] as Color).withOpacity(0.1)
                      : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? (option['color'] as Color)
                        : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: option['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      option['label'] as String,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (option['color'] as Color)
                            : AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSiteQualitySelector() {
    final qualityOptions = ['excellent', 'good', 'fair', 'poor'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Site Quality',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: qualityOptions.map((option) {
            final isSelected = _selectedSiteQuality == option;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSiteQuality = option;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primary.withOpacity(0.1)
                      : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColor.primary : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option.capitalize(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColor.primary : AppColor.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDamageSeveritySelector() {
    final severityOptions = ['none', 'minor', 'moderate', 'severe', 'critical'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage Severity',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: severityOptions.map((option) {
            final isSelected = _selectedDamageSeverity == option;
            Color chipColor;
            switch (option) {
              case 'none':
                chipColor = AppColor.success;
                break;
              case 'minor':
                chipColor = AppColor.secondary;
                break;
              case 'moderate':
                chipColor = AppColor.warning;
                break;
              case 'severe':
                chipColor = AppColor.accent;
                break;
              case 'critical':
                chipColor = AppColor.error;
                break;
              default:
                chipColor = AppColor.textSecondary;
            }

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDamageSeverity = option;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor.withOpacity(0.1)
                      : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? chipColor : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option.capitalize(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? chipColor : AppColor.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Images',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_selectedImages.isEmpty) _buildImagePlaceholder(),
        if (_selectedImages.isNotEmpty) _buildImagePreviewGrid(),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Row(
      children: [
        _buildImageActionButton(
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          onTap: () => _pickImage(ImageSource.camera),
        ),
        SizedBox(width: 12.w),
        _buildImageActionButton(
          icon: Icons.image_outlined,
          label: 'Gallery',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.primary, size: 32.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildImageActionButton(
              icon: Icons.add_a_photo_outlined,
              label: 'Add More',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading:
                                Icon(Icons.camera_alt, color: AppColor.primary),
                            title: Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading:
                                Icon(Icons.image, color: AppColor.secondary),
                            title: Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: List.generate(_selectedImages.length, (index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    _selectedImages[index],
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdditionalDetails = !_showAdditionalDetails;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showAdditionalDetails
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: AppColor.primary,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              _showAdditionalDetails
                  ? 'Hide Additional Details'
                  : 'Add Additional Details',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'Submit Survey',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
/*
// Main Form Screen
class TreeSurveyFormScreen extends StatefulWidget {
  final String projectId;
  final double latitude;
  final double longitude;
  static const route = '/TreeSurveyForm';

  const TreeSurveyFormScreen({super.key,required this.projectId,required this.latitude,required this.longitude});

  @override
  State<TreeSurveyFormScreen> createState() => _TreeSurveyFormScreenState();
}

class _TreeSurveyFormScreenState extends State<TreeSurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for required fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _girthController = TextEditingController();

  // Controllers for additional fields
  final TextEditingController _ownershipController = TextEditingController();
  final TextEditingController _canopyDiameterController = TextEditingController();
  final TextEditingController _estimatedAgeController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _threatsController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _fieldOfficerController = TextEditingController();

  // Selected values
  String? _selectedProjectId;
  TreeSpecies? _selectedSpecies;
  String? _selectedHealthStatus;
  String? _selectedSiteQuality;
  String? _selectedDamageSeverity;

  // Additional details toggle
  bool _showAdditionalDetails = false;

  // Images
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _heightController.dispose();
    _girthController.dispose();
    _ownershipController.dispose();
    _canopyDiameterController.dispose();
    _estimatedAgeController.dispose();
    _soilTypeController.dispose();
    _threatsController.dispose();
    _remarkController.dispose();
    _fieldOfficerController.dispose();
    super.dispose();
  }

  void _showSpeciesSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpeciesSearchBottomSheet(
        onSpeciesSelected: (species) {
          setState(() {
            _selectedSpecies = species;
          });
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecies == null) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please select the tree species',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if(_heightController.text.isEmpty){
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please enter the height',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if(_girthController.text.isEmpty){
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please enter the girth',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }
      if (_selectedHealthStatus == null) {
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.alert,
          label: 'Please select health status',
          backgroundColor: Colors.red,
          iconColor: Colors.white,
        );
        return;
      }


      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tree survey submitted successfully!'),
          backgroundColor: AppColor.success,
        ),
      );

      //(lat, lng)
      final request = TreeSurveyRequest(
        project: widget.projectId,
        species: _selectedSpecies!.id,
        location: {
        "type": "Point",
        "coordinates": [widget.latitude,widget.longitude],
        },
        ownership: _ownershipController.text.trim(),
        height: _heightController.text.trim(),
        girth: _girthController.text.trim(),
        canopyDiameter: _canopyDiameterController.text.trim(),
        estimatedAge: int.tryParse(_estimatedAgeController.text.trim()),
        healthStatus: _selectedHealthStatus!,
        soilType: _soilTypeController.text.trim(),
        siteQuality: _selectedSiteQuality,
        threats: _threatsController.text.trim(),
        damageSeverity: _selectedDamageSeverity,
        images: _selectedImages,
        remark: _remarkController.text.trim(),
        fieldOfficer: _fieldOfficerController.text.trim()
      );
      // Navigate back or clear form
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        'Tree Survey',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.grey.shade800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  // Layer selector button
                  SizedBox(width: 40,)
                ],
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Required Fields Section
                    _buildSectionHeader('Basic Information', isRequired: true),
                    SizedBox(height: 12.h),
                    /*
                    // Project Dropdown (Mock)
                    _buildProjectDropdown(),
                    SizedBox(height: 16.h),
                    
                     */

                    // Species Selection
                    _buildSpeciesSelector(),
                    SizedBox(height: 16.h),

                    // Location (Mock - you can add map integration)
                    _buildLocationField(),
                    SizedBox(height: 16.h),

                    // Height
                    _buildTextField(
                      controller: _heightController,
                      label: 'Height (meters)',
                      hint: 'e.g., 15.5',
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      suffixText: 'm',
                    ),
                    SizedBox(height: 16.h),

                    // Girth
                    _buildTextField(
                      controller: _girthController,
                      label: 'Girth at Breast Height (meters)',
                      hint: 'e.g., 1.2',
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      suffixText: 'm',
                    ),
                    SizedBox(height: 16.h),

                    // Health Status
                    _buildHealthStatusSelector(),
                    SizedBox(height: 16.h),
                    // Images
                    _buildImageSelector(),
                    SizedBox(height: 24.h),
                    // Additional Details Toggle Button
                    _buildAdditionalDetailsButton(),
                    SizedBox(height: 16.h),

                    // Additional Details Section (Collapsible)
                    if (_showAdditionalDetails) ...[
                      _buildSectionHeader('Additional Details', isRequired: false),
                      SizedBox(height: 12.h),

                      // Ownership
                      _buildTextField(
                        controller: _ownershipController,
                        label: 'Ownership',
                        hint: 'e.g., Public, Private',
                        isRequired: false,
                      ),
                      SizedBox(height: 16.h),

                      // Canopy Diameter
                      _buildTextField(
                        controller: _canopyDiameterController,
                        label: 'Canopy Diameter (meters)',
                        hint: 'e.g., 8.5',
                        isRequired: false,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        suffixText: 'm',
                      ),
                      SizedBox(height: 16.h),

                      // Estimated Age
                      _buildTextField(
                        controller: _estimatedAgeController,
                        label: 'Estimated Age (years)',
                        hint: 'e.g., 50',
                        isRequired: false,
                        keyboardType: TextInputType.number,
                        suffixText: 'yrs',
                      ),
                      SizedBox(height: 16.h),

                      // Soil Type
                      _buildTextField(
                        controller: _soilTypeController,
                        label: 'Soil Type',
                        hint: 'e.g., Loamy, Clay',
                        isRequired: false,
                      ),
                      SizedBox(height: 16.h),

                      // Site Quality
                      _buildSiteQualitySelector(),
                      SizedBox(height: 16.h),

                      // Threats
                      _buildTextField(
                        controller: _threatsController,
                        label: 'Threats',
                        hint: 'e.g., Pest infestation, Construction',
                        isRequired: false,
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.h),

                      // Damage Severity
                      _buildDamageSeveritySelector(),
                      SizedBox(height: 16.h),



                      // Remarks
                      _buildTextField(
                        controller: _remarkController,
                        label: 'Remarks',
                        hint: 'Any additional notes...',
                        isRequired: false,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),

                      // Field Officer
                      _buildTextField(
                        controller: _fieldOfficerController,
                        label: 'Field Officer',
                        hint: 'Officer name',
                        isRequired: false,
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ],
                ),
              ),
            ),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isRequired}) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        if (isRequired) ...[
          SizedBox(width: 4.w),
          Text(
            '*',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isRequired,
    TextInputType? keyboardType,
    String? suffixText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColor.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textMuted,
            ),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColor.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.error),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Project',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProjectId,
            decoration: InputDecoration(
              hintText: 'Select project',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textMuted,
              ),
              prefixIcon: Icon(Icons.folder_outlined, color: AppColor.primary, size: 22.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            items: [
              DropdownMenuItem(
                value: '1',
                child: Text('Central Park Tree Survey'),
              ),
              DropdownMenuItem(
                value: '2',
                child: Text('Brooklyn Bridge Green Belt'),
              ),
              DropdownMenuItem(
                value: '3',
                child: Text('Hudson Riverfront Restoration'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedProjectId = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Species',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _showSpeciesSearchDialog,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.border),
            ),
            child: Row(
              children: [
                Icon(Icons.park_outlined, color: AppColor.secondary, size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: _selectedSpecies == null
                      ? Text(
                    'Search and select species',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textMuted,
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSpecies!.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      Text(
                        _selectedSpecies!.scientificName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.search, color: AppColor.primary, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /*
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColor.accent, size: 22.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude',
                            style: AppFonts.regular.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.latitude != null
                                ? '${widget.latitude!.toStringAsFixed(8)}'
                                : '–',
                            style: AppFonts.regular.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textPrimary,
                              fontFamily: 'monospace', // optional: for better number alignment
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Longitude',
                            style: AppFonts.regular.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.longitude != null
                                ? '${widget.longitude!.toStringAsFixed(8)}'
                                : '–',
                            style: AppFonts.regular.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /*
              Expanded(
                child: Text(
                  'Latitude: ${widget.latitude} Longitude: ${widget.longitude}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.textMuted,
                  ),
                ),
              ),

               */
              // Icon(Icons.arrow_forward_ios, color: AppColor.textMuted, size: 16.sp),
            ],
          ),
        ),
      ],
    );
  }

   */
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColor.accent, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.latitude != null && widget.longitude != null
                          ? '${widget.latitude!.toStringAsFixed(6)}°, ${widget.longitude!.toStringAsFixed(6)}°'
                          : '–',
                      style: AppFonts.regular.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildHealthStatusSelector() {
    final healthOptions = [
      {'value': 'excellent', 'label': 'Excellent', 'color': AppColor.success},
      {'value': 'good', 'label': 'Good', 'color': AppColor.secondary},
      {'value': 'fair', 'label': 'Fair', 'color': AppColor.warning},
      {'value': 'poor', 'label': 'Poor', 'color': AppColor.accent},
      {'value': 'dying', 'label': 'Dying', 'color': AppColor.error},
      {'value': 'dead', 'label': 'Dead', 'color': AppColor.textMuted},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Health Status',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: healthOptions.map((option) {
            final isSelected = _selectedHealthStatus == option['value'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedHealthStatus = option['value'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (option['color'] as Color).withOpacity(0.1)
                      : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? (option['color'] as Color) : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: option['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      option['label'] as String,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? (option['color'] as Color) : AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSiteQualitySelector() {
    final qualityOptions = ['excellent', 'good', 'fair', 'poor'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Site Quality',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: qualityOptions.map((option) {
            final isSelected = _selectedSiteQuality == option;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSiteQuality = option;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary.withOpacity(0.1) : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColor.primary : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option.capitalize(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColor.primary : AppColor.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDamageSeveritySelector() {
    final severityOptions = ['none', 'minor', 'moderate', 'severe', 'critical'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage Severity',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: severityOptions.map((option) {
            final isSelected = _selectedDamageSeverity == option;
            Color chipColor;
            switch (option) {
              case 'none':
                chipColor = AppColor.success;
                break;
              case 'minor':
                chipColor = AppColor.secondary;
                break;
              case 'moderate':
                chipColor = AppColor.warning;
                break;
              case 'severe':
                chipColor = AppColor.accent;
                break;
              case 'critical':
                chipColor = AppColor.error;
                break;
              default:
                chipColor = AppColor.textSecondary;
            }

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDamageSeverity = option;
                });
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? chipColor.withOpacity(0.1) : AppColor.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? chipColor : AppColor.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option.capitalize(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? chipColor : AppColor.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () {
            // Open image picker
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open camera or gallery')),
            );
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.border, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: AppColor.primary, size: 40.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'Add Photos',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdditionalDetails = !_showAdditionalDetails;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showAdditionalDetails ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: AppColor.primary,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              _showAdditionalDetails ? 'Hide Additional Details' : 'Add Additional Details',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        height: 50.h,
        // margin: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary, AppColor.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
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

            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child:  Text(
                'Submit Survey',
                style: AppFonts.regular.copyWith(
                  color: AppColor.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
      Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'Submit Survey',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 */

class SpeciesSearchBottomSheet extends StatefulWidget {
  final Function(TreeSpecies) onSpeciesSelected;

  const SpeciesSearchBottomSheet({
    Key? key,
    required this.onSpeciesSelected,
  }) : super(key: key);

  @override
  State<SpeciesSearchBottomSheet> createState() =>
      _SpeciesSearchBottomSheetState();
}

class _SpeciesSearchBottomSheetState extends State<SpeciesSearchBottomSheet> {
  late TreeSpeciesBloc _speciesBloc;
  final TextEditingController _searchController = TextEditingController();
  List<TreeSpecies> _allSpecies = [];
  List<TreeSpecies> _filteredSpecies = [];

  @override
  void initState() {
    super.initState();
    _speciesBloc = TreeSpeciesBloc(
      TreeRepository(),
    );
    _speciesBloc.add(ApiFetch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speciesBloc.close();
    super.dispose();
  }

  // 🔁 Map API model → UI model
  TreeSpecies _mapToUiModel(TreeSpeciesData data) {
    return TreeSpecies(
      id: data.id,
      name: data.commonName,
      scientificName: data.scientificName,
    );
  }

  void _filterSpecies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSpecies = _allSpecies;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredSpecies = _allSpecies.where((species) {
          return species.name.toLowerCase().contains(lowerQuery) ||
              species.scientificName.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _speciesBloc,
      child: BlocConsumer<TreeSpeciesBloc,
          ApiState<TreeSpeciesResponseModel, ResponseModel>>(
        listener: (context, state) {
          if (state is ApiLoading) {
            EasyLoading.show(status: 'Loading species...');
          } else if (state
              is ApiSuccess<TreeSpeciesResponseModel, ResponseModel>) {
            EasyLoading.dismiss();
            final speciesList = state.data.data ?? [];
            final uiSpecies = speciesList.map(_mapToUiModel).toList();
            setState(() {
              _allSpecies = uiSpecies;
              _filteredSpecies = uiSpecies;
            });
          } else if (state
              is ApiFailure<TreeSpeciesResponseModel, ResponseModel>) {
            EasyLoading.dismiss();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.data.toString())),
            );
            // Fallback to mock data if needed
            // setState(() {
            //   _allSpecies = TreeSpecies.mockSpecies();
            //   _filteredSpecies = _allSpecies;
            // });
          } else if (state is TokenExpired) {
            EasyLoading.dismiss();
            // AppRoute.pushReplacement(context, '/login', arguments: {});
          }
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppColor.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(Icons.park_outlined,
                          color: AppColor.secondary, size: 24.sp),
                      SizedBox(width: 12.w),
                      Text(
                        'Select Tree Species',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColor.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterSpecies,
                    decoration: InputDecoration(
                      hintText: 'Search by name or scientific name...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textMuted,
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: AppColor.textMuted, size: 22.sp),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: AppColor.textMuted, size: 20.sp),
                              onPressed: () {
                                _searchController.clear();
                                _filterSpecies('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColor.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColor.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColor.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            BorderSide(color: AppColor.primary, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Species list
                Expanded(
                  child: (() {
                    if (state is ApiLoading) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: AppColor.primary));
                    } else if (state is ApiFailure || state is TokenExpired) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: AppColor.error),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load species',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Use filtered list (could be empty)
                      if (_filteredSpecies.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60.sp,
                                color: AppColor.textMuted,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No species found',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _filteredSpecies.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            final species = _filteredSpecies[index];
                            return InkWell(
                              onTap: () {
                                widget.onSpeciesSelected(species);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColor.cardBackground,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: AppColor.border.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44.w,
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        color:
                                            AppColor.secondary.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Icon(
                                        Icons.park_outlined,
                                        color: AppColor.secondary,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            species.name,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            species.scientificName,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColor.textSecondary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColor.textMuted,
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  })(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Keep your extension if used elsewhere
// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${this.substring(1)}";
//   }
// }
