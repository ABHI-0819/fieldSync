import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/config/themes/app_color.dart';
import '../../features/survey/models/tree_survey_list_model.dart';

class TreeMarkerBottomSheet extends StatelessWidget {
  final TreeSurveyData treeData;
  final VoidCallback onDelete;
  final VoidCallback onNavigate;

  const TreeMarkerBottomSheet({
    super.key,
    required this.treeData,
    required this.onDelete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Tree ID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.park,
                    color: AppColor.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treeData.tid ?? 'N/A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        treeData.projectCode ?? 'Unknown Project',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildHealthBadge(treeData.healthStatus),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Species Information
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.secondaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColor.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: AppColor.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Species',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  treeData.speciesName?? 'Unknown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treeData.speciesNameMarathi?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treeData.speciesScientificName ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColor.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tree Measurements Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: _buildMeasurementCard(
                    icon: Icons.height,
                    label: 'Height',
                    value: '${treeData.height ?? 'N/A'} m',
                    color: AppColor.accent,
                  ),
                ),
                Expanded(
                  child: _buildMeasurementCard(
                    icon: Icons.straighten,
                    label: 'Girth',
                    value: '${treeData.girth ?? 'N/A'} m',
                    color: AppColor.skyBlue,
                  ),
                ),
                Expanded(
                  child: _buildMeasurementCard(
                    icon: Icons.circle_outlined,
                    label: 'Diameter',
                    value: '${treeData.diameterCm.toStringAsFixed(1) ?? 'N/A'} cm',
                    color: AppColor.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Additional Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Project',
                  value: treeData.projectName ?? 'Unknown',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Mapped by',
                  value: treeData.createdByName ?? 'Unknown',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Age Group',
                  value: treeData.treeAgeGroup ?? 'Unknown',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    icon: Icon(Icons.delete_outline,color: AppColor.error, size: 20),
                    label: Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.error,
                      side: BorderSide(color: AppColor.error, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Navigate Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onNavigate();
                    },
                    icon: Icon(Icons.navigation,color: AppColor.white, size: 20),
                    label: Text('Navigate to Tree'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status?.toLowerCase()) {
      case 'good':
        bgColor = AppColor.success.withOpacity(0.1);
        textColor = AppColor.success;
        label = 'Good';
        break;
      case 'moderate':
        bgColor = AppColor.warning.withOpacity(0.1);
        textColor = AppColor.warning;
        label = 'Moderate';
        break;
      case 'poor':
        bgColor = AppColor.error.withOpacity(0.1);
        textColor = AppColor.error;
        label = 'Poor';
        break;
      default:
        bgColor = AppColor.border;
        textColor = AppColor.textMuted;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMeasurementCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        spacing: 4.w,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColor.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColor.textMuted,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.textMuted,
          ),
        ),
        Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// Usage Example:
/*
void showTreeDetails(BuildContext context, Map<String, dynamic> treeData) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TreeMarkerBottomSheet(
      treeData: treeData,
      onDelete: () {
        // Handle delete action
        print('Delete tree: ${treeData['tid']}');
      },
      onNavigate: () {
        // Handle navigation action
        print('Navigate to: ${treeData['location']['coordinates']}');
      },
    ),
  );
}

 */