import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/sync/models/offline_project.dart';
import '../../features/sync/models/offline_species.dart';
import '../../features/sync/models/offline_tree_survey.dart';

class HiveSetup {
  static const String projectsBoxName = 'offline_projects';
  static const String speciesBoxName = 'offline_species';
  static const String surveysBoxName = 'offline_surveys';

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Adapters
    Hive.registerAdapter(OfflineProjectAdapter());
    Hive.registerAdapter(OfflineSpeciesAdapter());
    Hive.registerAdapter(OfflineTreeSurveyAdapter());

    // Open Boxes
    await Hive.openBox<OfflineProject>(projectsBoxName);
    await Hive.openBox<OfflineSpecies>(speciesBoxName);
    await Hive.openBox<OfflineTreeSurvey>(surveysBoxName);
  }

  static Box<OfflineProject> get projectsBox => Hive.box<OfflineProject>(projectsBoxName);
  static Box<OfflineSpecies> get speciesBox => Hive.box<OfflineSpecies>(speciesBoxName);
  static Box<OfflineTreeSurvey> get surveysBox => Hive.box<OfflineTreeSurvey>(surveysBoxName);
}
