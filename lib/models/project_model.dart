import 'package:traces_of_the_deep_reef/enum/my_enums.dart';

class OceanographicToolModel {
  String id;
  String oceanicRegistryLog;
  InstrumentClassification instrumentClassification;
  String artisanHallmark;
  String era;
  String calibrationSite;
  OceanDepthZone oceanDepthZone;
  ValvingSealingMechanics valvingSealingMechanics;
  String soundingPressureBounds;
  CompositionMetallurgy compositionMetallurgy;
  String ballastMassProfile;
  String physicalProportions;
  PreservationSoundness preservationSoundness;
  String calibrationMarks;
  String expeditionGroundZero;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  OceanographicToolModel({
    required this.id,
    required this.oceanicRegistryLog,
    required this.instrumentClassification,
    required this.artisanHallmark,
    required this.era,
    required this.calibrationSite,
    required this.oceanDepthZone,
    required this.valvingSealingMechanics,
    required this.soundingPressureBounds,
    required this.compositionMetallurgy,
    required this.ballastMassProfile,
    required this.physicalProportions,
    required this.preservationSoundness,
    required this.calibrationMarks,
    required this.expeditionGroundZero,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'oceanicRegistryLog': oceanicRegistryLog,
        'instrumentClassification': instrumentClassification.name,
        'artisanHallmark': artisanHallmark,
        'era': era,
        'calibrationSite': calibrationSite,
        'oceanDepthZone': oceanDepthZone.name,
        'valvingSealingMechanics': valvingSealingMechanics.name,
        'soundingPressureBounds': soundingPressureBounds,
        'compositionMetallurgy': compositionMetallurgy.name,
        'ballastMassProfile': ballastMassProfile,
        'physicalProportions': physicalProportions,
        'preservationSoundness': preservationSoundness.name,
        'calibrationMarks': calibrationMarks,
        'expeditionGroundZero': expeditionGroundZero,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory OceanographicToolModel.fromJson(Map<String, dynamic> json) =>
      OceanographicToolModel(
        id: json['id'] ?? '',
        oceanicRegistryLog: json['oceanicRegistryLog'] ?? '',
        instrumentClassification: InstrumentClassification.values
                .asNameMap()[json['instrumentClassification']] ??
            InstrumentClassification.other,
        artisanHallmark: json['artisanHallmark'] ?? '',
        era: json['era'] ?? '',
        calibrationSite: json['calibrationSite'] ?? '',
        oceanDepthZone: OceanDepthZone.values
                .asNameMap()[json['oceanDepthZone']] ??
            OceanDepthZone.epipelagic,
        valvingSealingMechanics: ValvingSealingMechanics.values
                .asNameMap()[json['valvingSealingMechanics']] ??
            ValvingSealingMechanics.other,
        soundingPressureBounds: json['soundingPressureBounds'] ?? '',
        compositionMetallurgy: CompositionMetallurgy.values
                .asNameMap()[json['compositionMetallurgy']] ??
            CompositionMetallurgy.mixedUnknown,
        ballastMassProfile: json['ballastMassProfile'] ?? '',
        physicalProportions: json['physicalProportions'] ?? '',
        preservationSoundness: PreservationSoundness.values
                .asNameMap()[json['preservationSoundness']] ??
            PreservationSoundness.unknown,
        calibrationMarks: json['calibrationMarks'] ?? '',
        expeditionGroundZero: json['expeditionGroundZero'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
