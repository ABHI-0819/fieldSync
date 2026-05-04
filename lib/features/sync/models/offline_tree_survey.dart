import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class OfflineTreeSurvey extends HiveObject {
  @HiveField(0)
  final String id; // This is used as client_uuid
  @HiveField(1)
  final String project;
  @HiveField(2)
  final String species;
  @HiveField(3)
  final double latitude;
  @HiveField(4)
  final double longitude;
  @HiveField(5)
  final String height;
  @HiveField(6)
  final String girth;
  @HiveField(7)
  final String healthStatus;
  @HiveField(8)
  final String? ownership;
  @HiveField(9)
  final String? canopyDiameter;
  @HiveField(10)
  final int? estimatedAge;
  @HiveField(11)
  final String? soilType;
  @HiveField(12)
  final String? siteQuality;
  @HiveField(13)
  final String? threats;
  @HiveField(14)
  final String? damageSeverity;
  @HiveField(15)
  final List<String> imagePaths;
  @HiveField(16)
  final String? remark;
  @HiveField(17)
  final String? fieldOfficer;
  @HiveField(18)
  bool isSynced;
  @HiveField(19)
  String? serverId;
  @HiveField(20)
  String? tid;
  @HiveField(21)
  DateTime? surveyedAt;

  OfflineTreeSurvey({
    required this.id,
    required this.project,
    required this.species,
    required this.latitude,
    required this.longitude,
    required this.height,
    required this.girth,
    required this.healthStatus,
    this.ownership,
    this.canopyDiameter,
    this.estimatedAge,
    this.soilType,
    this.siteQuality,
    this.threats,
    this.damageSeverity,
    required this.imagePaths,
    this.remark,
    this.fieldOfficer,
    this.isSynced = false,
    this.serverId,
    this.tid,
    this.surveyedAt,
  });
}

// I'll use the Hive generator style if possible, but the user has a manual adapter.
// Actually, I'll update the manual adapter to match the new fields.

class OfflineTreeSurveyAdapter extends TypeAdapter<OfflineTreeSurvey> {
  @override
  final int typeId = 2;

  @override
  OfflineTreeSurvey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineTreeSurvey(
      id: fields[0] as String,
      project: fields[1] as String,
      species: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      height: fields[5] as String,
      girth: fields[6] as String,
      healthStatus: fields[7] as String,
      ownership: fields[8] as String?,
      canopyDiameter: fields[9] as String?,
      estimatedAge: fields[10] as int?,
      soilType: fields[11] as String?,
      siteQuality: fields[12] as String?,
      threats: fields[13] as String?,
      damageSeverity: fields[14] as String?,
      imagePaths: (fields[15] as List).cast<String>(),
      remark: fields[16] as String?,
      fieldOfficer: fields[17] as String?,
      isSynced: fields[18] as bool,
      serverId: fields[19] as String?,
      tid: fields[20] as String?,
      surveyedAt: fields[21] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineTreeSurvey obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.project)
      ..writeByte(2)..write(obj.species)
      ..writeByte(3)..write(obj.latitude)
      ..writeByte(4)..write(obj.longitude)
      ..writeByte(5)..write(obj.height)
      ..writeByte(6)..write(obj.girth)
      ..writeByte(7)..write(obj.healthStatus)
      ..writeByte(8)..write(obj.ownership)
      ..writeByte(9)..write(obj.canopyDiameter)
      ..writeByte(10)..write(obj.estimatedAge)
      ..writeByte(11)..write(obj.soilType)
      ..writeByte(12)..write(obj.siteQuality)
      ..writeByte(13)..write(obj.threats)
      ..writeByte(14)..write(obj.damageSeverity)
      ..writeByte(15)..write(obj.imagePaths)
      ..writeByte(16)..write(obj.remark)
      ..writeByte(17)..write(obj.fieldOfficer)
      ..writeByte(18)..write(obj.isSynced)
      ..writeByte(19)..write(obj.serverId)
      ..writeByte(20)..write(obj.tid)
      ..writeByte(21)..write(obj.surveyedAt);
  }
}
