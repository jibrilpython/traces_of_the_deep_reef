import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _oceanicRegistryLog = '';
  InstrumentClassification _instrumentClassification =
      InstrumentClassification.reversingThermometer;
  String _artisanHallmark = '';
  String _era = '';
  String _calibrationSite = '';
  OceanDepthZone _oceanDepthZone = OceanDepthZone.epipelagic;
  ValvingSealingMechanics _valvingSealingMechanics =
      ValvingSealingMechanics.dropWeightMessenger;
  String _soundingPressureBounds = '';
  CompositionMetallurgy _compositionMetallurgy =
      CompositionMetallurgy.tinnedBrass;
  String _ballastMassProfile = '';
  String _physicalProportions = '';
  PreservationSoundness _preservationSoundness = PreservationSoundness.unknown;
  String _calibrationMarks = '';
  String _expeditionGroundZero = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get oceanicRegistryLog => _oceanicRegistryLog;
  InstrumentClassification get instrumentClassification =>
      _instrumentClassification;
  String get artisanHallmark => _artisanHallmark;
  String get era => _era;
  String get calibrationSite => _calibrationSite;
  OceanDepthZone get oceanDepthZone => _oceanDepthZone;
  ValvingSealingMechanics get valvingSealingMechanics =>
      _valvingSealingMechanics;
  String get soundingPressureBounds => _soundingPressureBounds;
  CompositionMetallurgy get compositionMetallurgy => _compositionMetallurgy;
  String get ballastMassProfile => _ballastMassProfile;
  String get physicalProportions => _physicalProportions;
  PreservationSoundness get preservationSoundness => _preservationSoundness;
  String get calibrationMarks => _calibrationMarks;
  String get expeditionGroundZero => _expeditionGroundZero;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set oceanicRegistryLog(String v) {
    _oceanicRegistryLog = v;
    notifyListeners();
  }

  set instrumentClassification(InstrumentClassification v) {
    _instrumentClassification = v;
    notifyListeners();
  }

  set artisanHallmark(String v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set era(String v) {
    _era = v;
    notifyListeners();
  }

  set calibrationSite(String v) {
    _calibrationSite = v;
    notifyListeners();
  }

  set oceanDepthZone(OceanDepthZone v) {
    _oceanDepthZone = v;
    notifyListeners();
  }

  set valvingSealingMechanics(ValvingSealingMechanics v) {
    _valvingSealingMechanics = v;
    notifyListeners();
  }

  set soundingPressureBounds(String v) {
    _soundingPressureBounds = v;
    notifyListeners();
  }

  set compositionMetallurgy(CompositionMetallurgy v) {
    _compositionMetallurgy = v;
    notifyListeners();
  }

  set ballastMassProfile(String v) {
    _ballastMassProfile = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set preservationSoundness(PreservationSoundness v) {
    _preservationSoundness = v;
    notifyListeners();
  }

  set calibrationMarks(String v) {
    _calibrationMarks = v;
    notifyListeners();
  }

  set expeditionGroundZero(String v) {
    _expeditionGroundZero = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _oceanicRegistryLog = '';
    _instrumentClassification = InstrumentClassification.reversingThermometer;
    _artisanHallmark = '';
    _era = '';
    _calibrationSite = '';
    _oceanDepthZone = OceanDepthZone.epipelagic;
    _valvingSealingMechanics = ValvingSealingMechanics.dropWeightMessenger;
    _soundingPressureBounds = '';
    _compositionMetallurgy = CompositionMetallurgy.tinnedBrass;
    _ballastMassProfile = '';
    _physicalProportions = '';
    _preservationSoundness = PreservationSoundness.unknown;
    _calibrationMarks = '';
    _expeditionGroundZero = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
