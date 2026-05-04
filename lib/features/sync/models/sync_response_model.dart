import 'dart:convert';

SyncResponseList syncResponseListFromJson(String str) =>
    SyncResponseList.fromJson(json.decode(str));

class SyncResponseList {
  final List<SyncResponseItem> results;

  SyncResponseList({required this.results});

  factory SyncResponseList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      return SyncResponseList(
        results: List<SyncResponseItem>.from(
          json['results'].map((x) => SyncResponseItem.fromJson(x)),
        ),
      );
    }
    // Handle list directly if the API returns a list
    if (json is List) {
       return SyncResponseList(
        results: List<SyncResponseItem>.from(
          (json as List).map((x) => SyncResponseItem.fromJson(x)),
        ),
      );
    }
    return SyncResponseList(results: []);
  }
}

class SyncResponseItem {
  final String? clientUuid;
  final String? serverId;
  final String? tid;
  final bool synced;
  final String? status; // e.g. "success", "duplicate", "failed"
  final String? error;

  SyncResponseItem({
    this.clientUuid,
    this.serverId,
    this.tid,
    required this.synced,
    this.status,
    this.error,
  });

  factory SyncResponseItem.fromJson(Map<String, dynamic> json) {
    return SyncResponseItem(
      clientUuid: json['client_uuid']?.toString(),
      serverId: json['server_id']?.toString() ?? json['id']?.toString(),
      tid: json['tid']?.toString(),
      synced: json['synced'] == true ||
          json['status'] == 'success' ||
          json['status'] == 'created' ||
          json['status'] == 'duplicate',
      status: json['status']?.toString(),
      error: json['error']?.toString(),
    );
  }
}
