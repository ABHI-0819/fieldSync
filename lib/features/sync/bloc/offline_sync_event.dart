import 'package:equatable/equatable.dart';

abstract class OfflineSyncEvent extends Equatable {
  const OfflineSyncEvent();

  @override
  List<Object> get props => [];
}

class CheckOfflineResources extends OfflineSyncEvent {
  final String projectId;

  const CheckOfflineResources({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class DownloadResources extends OfflineSyncEvent {
  final String projectId;

  const DownloadResources({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class RetryDownload extends OfflineSyncEvent {
  final String projectId;

  const RetryDownload({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

class SyncOfflineData extends OfflineSyncEvent {}

class ResetSyncState extends OfflineSyncEvent {}
