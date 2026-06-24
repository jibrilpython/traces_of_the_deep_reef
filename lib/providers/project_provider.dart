import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';
import 'package:traces_of_the_deep_reef/providers/image_provider.dart';
import 'package:traces_of_the_deep_reef/providers/input_provider.dart';
import 'package:traces_of_the_deep_reef/utils/const.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<OceanographicToolModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'tdr_entries_v1';
  final _uuid = const Uuid();

  void _sortEntries() {
    entries.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  }

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => OceanographicToolModel.fromJson(item))
            .toList();
        _sortEntries();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    final registry = p.oceanicRegistryLog.trim().isEmpty
        ? generateRegistryCode()
        : p.oceanicRegistryLog.trim();

    final newEntry = OceanographicToolModel(
      id: _uuid.v4(),
      oceanicRegistryLog: registry,
      instrumentClassification: p.instrumentClassification,
      artisanHallmark: p.artisanHallmark,
      era: p.era,
      calibrationSite: p.calibrationSite,
      oceanDepthZone: p.oceanDepthZone,
      valvingSealingMechanics: p.valvingSealingMechanics,
      soundingPressureBounds: p.soundingPressureBounds,
      compositionMetallurgy: p.compositionMetallurgy,
      ballastMassProfile: p.ballastMassProfile,
      physicalProportions: p.physicalProportions,
      preservationSoundness: p.preservationSoundness,
      calibrationMarks: p.calibrationMarks,
      expeditionGroundZero: p.expeditionGroundZero,
      notes: p.notes,
      photoPath:
          imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: DateTime.now(),
    );

    entries = [newEntry, ...entries];
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    final updatedEntry = OceanographicToolModel(
      id: existing.id,
      oceanicRegistryLog: p.oceanicRegistryLog.trim().isEmpty
          ? existing.oceanicRegistryLog
          : p.oceanicRegistryLog.trim(),
      instrumentClassification: p.instrumentClassification,
      artisanHallmark: p.artisanHallmark,
      era: p.era,
      calibrationSite: p.calibrationSite,
      oceanDepthZone: p.oceanDepthZone,
      valvingSealingMechanics: p.valvingSealingMechanics,
      soundingPressureBounds: p.soundingPressureBounds,
      compositionMetallurgy: p.compositionMetallurgy,
      ballastMassProfile: p.ballastMassProfile,
      physicalProportions: p.physicalProportions,
      preservationSoundness: p.preservationSoundness,
      calibrationMarks: p.calibrationMarks,
      expeditionGroundZero: p.expeditionGroundZero,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    final newList = List<OceanographicToolModel>.from(entries);
    newList[index] = updatedEntry;
    entries = newList;

    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<OceanographicToolModel>.from(entries);
    newList.removeAt(index);
    entries = newList;

    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.oceanicRegistryLog = entry.oceanicRegistryLog;
    p.instrumentClassification = entry.instrumentClassification;
    p.artisanHallmark = entry.artisanHallmark;
    p.era = entry.era;
    p.calibrationSite = entry.calibrationSite;
    p.oceanDepthZone = entry.oceanDepthZone;
    p.valvingSealingMechanics = entry.valvingSealingMechanics;
    p.soundingPressureBounds = entry.soundingPressureBounds;
    p.compositionMetallurgy = entry.compositionMetallurgy;
    p.ballastMassProfile = entry.ballastMassProfile;
    p.physicalProportions = entry.physicalProportions;
    p.preservationSoundness = entry.preservationSoundness;
    p.calibrationMarks = entry.calibrationMarks;
    p.expeditionGroundZero = entry.expeditionGroundZero;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;

    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
