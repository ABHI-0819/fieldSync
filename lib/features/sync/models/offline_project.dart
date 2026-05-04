import 'package:hive/hive.dart';

class OfflineProject extends HiveObject {
  final String id;
  final String name;
  final String code;
  final String locationName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final List<List<double>>? polygonData; // Added for map boundary [lat, lng]

  OfflineProject({
    required this.id,
    required this.name,
    required this.code,
    required this.locationName,
    this.startDate,
    this.endDate,
    required this.status,
    this.polygonData,
  });
}

class OfflineProjectAdapter extends TypeAdapter<OfflineProject> {
  @override
  final int typeId = 0;

  @override
  OfflineProject read(BinaryReader reader) {
    return OfflineProject(
      id: reader.read() as String,
      name: reader.read() as String,
      code: reader.read() as String,
      locationName: reader.read() as String,
      startDate: reader.read() as DateTime?,
      endDate: reader.read() as DateTime?,
      status: reader.read() as String,
      polygonData: (reader.read() as List?)
          ?.map((e) => (e as List).cast<double>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, OfflineProject obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.code);
    writer.write(obj.locationName);
    writer.write(obj.startDate);
    writer.write(obj.endDate);
    writer.write(obj.status);
    writer.write(obj.polygonData);
  }
}
