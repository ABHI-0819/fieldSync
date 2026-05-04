import 'package:equatable/equatable.dart';

abstract class OfflineSyncState extends Equatable {
  const OfflineSyncState();

  @override
  List<Object?> get props => [];
}

class OfflineSyncInitial extends OfflineSyncState {}

class OfflineSyncChecking extends OfflineSyncState {}

enum SyncTaskStatus { pending, downloading, downloaded }

class OfflineSyncDownloading extends OfflineSyncState {
  final double overallProgress; // 0.0 to 1.0
  final Map<String, SyncTaskStatus> taskStatuses;
  final Map<String, double> taskProgresses; // specific progress for tasks like 65%

  const OfflineSyncDownloading({
    required this.overallProgress,
    required this.taskStatuses,
    required this.taskProgresses,
  });

  @override
  List<Object?> get props => [overallProgress, taskStatuses, taskProgresses];
}

class OfflineSyncReady extends OfflineSyncState {}

class OfflineSyncingData extends OfflineSyncState {
  final int total;
  final int current;

  const OfflineSyncingData({required this.total, required this.current});

  @override
  List<Object?> get props => [total, current];
}

class OfflineSyncCompleted extends OfflineSyncState {}

class OfflineSyncError extends OfflineSyncState {
  final String message;

  const OfflineSyncError({required this.message});

  @override
  List<Object?> get props => [message];
}
