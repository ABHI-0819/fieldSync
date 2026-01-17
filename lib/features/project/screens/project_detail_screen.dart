
import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/common/models/response.mode.dart';
import 'package:fieldsync/core/config/route/app_route.dart';
import 'package:fieldsync/features/maps/screens/map_screen.dart';
import 'package:fieldsync/features/project/bloc/project_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/repository/project_repository.dart';
import '../../../common/widgets/common_gradient_button.dart';
import '../../../core/config/themes/app_color.dart';


// 👇 Your models & bloc

import '../models/project_dashboard_response_model.dart';

@RoutePage()
class ProjectDetailScreen extends StatefulWidget {
  static const route = '/project-detail';
  final String projectId;

  const ProjectDetailScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectDashboardBloc _projectDashboardBloc;

  @override
  void initState() {
    super.initState();
    _projectDashboardBloc = ProjectDashboardBloc(
      ProjectRepository(),
    );
    _projectDashboardBloc.add(ApiFetch(projectId: widget.projectId));
  }

  @override
  void dispose() {
    _projectDashboardBloc.close();
    super.dispose();
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return '–';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.background,
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
                        'Project Details',
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
      body: BlocProvider.value(
        value: _projectDashboardBloc,
        child: BlocBuilder<ProjectDashboardBloc,
            ApiState<ProjectDashboardResponse, ResponseModel>>(
          builder: (context, state) {
            if (state is ApiLoading) {
              return Center(child: CircularProgressIndicator(color: AppColor.primary));
            }

            if (state is ApiFailure<ProjectDashboardResponse,ResponseModel>) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: AppColor.error),
                    SizedBox(height: 16),
                    Text(
                      state.error.message ?? 'Failed to load project data',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.textPrimary, fontSize: 16),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _projectDashboardBloc.add(ApiFetch(projectId: widget.projectId));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                      child: Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (state is ApiSuccess<ProjectDashboardResponse,ResponseModel>) {
              final data = state.data.data;
              final overview = data.overview;
              final stats = data.stats;
              final surveyProgress = data.surveyProgress;
              final recentSurveys = data.recentSurveys;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overview.name,
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            overview.code,
                            style: TextStyle(
                              color: AppColor.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                    // Compact Project Overview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.location_on_outlined,
                              label: overview.locationName,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              label:
                              '${_formatDateShort(overview.startDate)} - ${_formatDateShort(overview.endDate)}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(overview.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              overview.status.toUpperCase(),
                              style: const TextStyle(
                                color: AppColor.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Compact Stats Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColor.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.people_outline,
                                        label: 'Team',
                                        value: stats.teamSize.toString(),
                                        color: AppColor.secondary,
                                      ),
                                    ),
                                    Container(width: 1, height: 40, color: AppColor.divider),
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.assignment_outlined,
                                        label: 'Surveys',
                                        value: stats.totalSurveys.toString(),
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    Container(width: 1, height: 40, color: AppColor.divider),
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.check_circle_outline,
                                        label: 'Done',
                                        value: stats.completedSurveys.toString(),
                                        color: AppColor.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(color: AppColor.divider, height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.park_outlined,
                                        label: 'Trees',
                                        value: stats.totalTrees.toString(),
                                        color: AppColor.secondaryDark,
                                      ),
                                    ),
                                    Container(width: 1, height: 40, color: AppColor.divider),
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.nature_outlined,
                                        label: 'Species',
                                        value: stats.speciesDiversity.toString(),
                                        color: AppColor.accent,
                                      ),
                                    ),
                                    Container(width: 1, height: 40, color: AppColor.divider),
                                    Expanded(
                                      child: _CompactStat(
                                        icon: Icons.landscape_outlined,
                                        label: 'Area (ha)',
                                        value: stats.areaHectares.toStringAsFixed(0),
                                        color: AppColor.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Survey Progress
                    if (surveyProgress.any((p) => p.surveysCount > 0))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly Progress',
                              style: TextStyle(
                                color: AppColor.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColor.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.border),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Month',
                                          style: TextStyle(
                                            color: AppColor.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Surveys',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColor.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Carbon',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: AppColor.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(color: AppColor.divider, height: 1),
                                  const SizedBox(height: 8),
                                  ...surveyProgress
                                      .where((p) => p.surveysCount > 0)
                                      .map((progress) {
                                    return _ProgressRow(
                                      month: progress.monthName,
                                      surveys: progress.surveysCount,
                                      carbon: progress.carbonSequestered,
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Progress Overview Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Progress Overview',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Survey Completion',
                                      style: TextStyle(
                                        color: AppColor.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${stats.completedSurveys} / ${stats.totalTrees}',
                                      style: const TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: stats.totalSurveys > 0
                                        ? stats.completedSurveys / stats.totalSurveys
                                        : 0.0,
                                    backgroundColor: AppColor.divider,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColor.secondary),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stats.totalSurveys > 0
                                          ? '${((stats.completedSurveys / stats.totalSurveys) * 100).toStringAsFixed(0)}% Complete'
                                          : '0% Complete',
                                      style: const TextStyle(
                                        color: AppColor.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${stats.totalSurveys - stats.completedSurveys} Remaining',
                                      style: const TextStyle(
                                        color: AppColor.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Recent Surveys
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Surveys',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (recentSurveys.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColor.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColor.border),
                              ),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.assignment_outlined, color: AppColor.textMuted, size: 36),
                                    SizedBox(height: 8),
                                    Text(
                                      'No surveys yet',
                                      style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...recentSurveys.map((survey) => _CompactSurveyCard(survey: survey as Map<String, dynamic>)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
bottomNavigationBar: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: CommonGradientButton(
  text: 'Continue',
  onTap: onContinue,
),
    ),
  ),
    );
  }

  void onContinue() {
    context.router.push(MapRoute(projectId: widget.projectId));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColor.success;
      case 'completed':
        return AppColor.grey;
      case 'planning':
        return AppColor.accent;
      default:
        return AppColor.primary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.white, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColor.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompactStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColor.textMuted,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String month;
  final int surveys;
  final double carbon;

  const _ProgressRow({
    required this.month,
    required this.surveys,
    required this.carbon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              month,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$surveys',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${carbon.toStringAsFixed(1)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColor.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactSurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _CompactSurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.secondaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.park, color: AppColor.secondaryDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey['tree_species'] ?? 'Unknown Species',
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${survey['surveyed_by'] ?? 'Unknown'} • ${survey['date'] ?? 'No date'}',
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              survey['health'] ?? 'N/A',
              style: const TextStyle(
                color: AppColor.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

