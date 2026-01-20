import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/location_bloc.dart';
import '../bloc/location_state.dart'; // update import path

class GpsAccuracyIndicator extends StatelessWidget {
  const GpsAccuracyIndicator({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      buildWhen: (previous, current) =>
          previous.accuracy != current.accuracy,
      builder: (context, state) {
        final accuracy = state.accuracy;

        if (accuracy == null) {
          return const SizedBox.shrink();
        }

        final color = _getAccuracyColor(accuracy);

        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.gps_fixed,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                '±${accuracy.toInt()}m',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 10) return Colors.green;
    if (accuracy < 50) return Colors.orange;
    return Colors.red;
  }
}
