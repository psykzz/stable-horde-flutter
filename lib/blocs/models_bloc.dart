import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stable_horde_flutter/model/stable_horde_model.dart';

class _ModelsBloc {
  List<StableHordeModel>? _cachedModels;

  Future<List<StableHordeModel>> getModels() async {
    if (_cachedModels != null) {
      return _cachedModels!;
    }

    final models = await _getModels();

    models.sort((a, b) => b.workerCount.compareTo(a.workerCount));

    _cachedModels = await _getModelDetails(models);
    return _cachedModels!;
  }

  Future<List<StableHordeBaseModel>> _getModels() async {
    final response = await http.get(
      Uri.parse(
        'https://stablehorde.net/api/v2/status/models',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get models: '
        '${response.statusCode} ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body) as List;

    final List<StableHordeBaseModel> models = [];
    for (final entry in jsonResponse) {
      final count = entry['count'];
      if (count == 0) continue;
      models.add(
        StableHordeBaseModel(
          entry['name'],
          count,
        ),
      );
    }

    return models;
  }

  Future<List<StableHordeModel>> _getModelDetails(
    List<StableHordeBaseModel> models,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/Sygil-Dev/nataili-model-reference/main/db.json',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get models: '
        '${response.statusCode} ${response.body}',
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

    final List<StableHordeModel> modelsWithDetails = [];
    for (final model in models) {
      final details = jsonResponse[model.name];
      final showcases = details['showcases'];
      if (showcases == null) {
        print('Warning: skipping ${model.name} because it has no showcases');
        continue;
      }

      modelsWithDetails.add(
        StableHordeModel(
          model.name,
          model.workerCount,
          details['description'],
          showcases[0],
        ),
      );
    }

    return modelsWithDetails;
  }
}

final modelsBloc = _ModelsBloc();