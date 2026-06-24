import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:traces_of_the_deep_reef/models/project_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<OceanographicToolModel> filteredList(
      List<OceanographicToolModel> list) {
    if (searchQuery.isEmpty) {
      return list;
    } else {
      final query = searchQuery.toLowerCase();
      return list
          .where((item) =>
              item.oceanicRegistryLog.toLowerCase().contains(query) ||
              item.artisanHallmark.toLowerCase().contains(query) ||
              item.calibrationSite.toLowerCase().contains(query) ||
              item.expeditionGroundZero.toLowerCase().contains(query) ||
              item.era.toLowerCase().contains(query) ||
              item.instrumentClassification.label
                  .toLowerCase()
                  .contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
