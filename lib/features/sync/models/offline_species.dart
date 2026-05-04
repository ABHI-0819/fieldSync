import 'package:hive/hive.dart';

class OfflineSpecies extends HiveObject {
  final String id;
  final String name;
  final String scientificName;

  OfflineSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
  });
}

class OfflineSpeciesAdapter extends TypeAdapter<OfflineSpecies> {
  @override
  final int typeId = 1;

  @override
  OfflineSpecies read(BinaryReader reader) {
    return OfflineSpecies(
      id: reader.read() as String,
      name: reader.read() as String,
      scientificName: reader.read() as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineSpecies obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.scientificName);
  }
}
