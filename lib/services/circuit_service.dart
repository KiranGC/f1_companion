import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/circuit_info.dart';

abstract class CircuitService {
  Future<CircuitInfo?> getCircuitInfo(String circuitInfoUrl);
  Future<CircuitInfo?> getCircuitInfoByKey(int circuitKey, int year);
}

class HttpCircuitService implements CircuitService {
  final http.Client _client;

  HttpCircuitService(this._client);

  /// Fetches [CircuitInfo] from the provided [circuitInfoUrl].
  @override
  Future<CircuitInfo?> getCircuitInfo(String circuitInfoUrl) async {
    try {
      final response = await _client.get(Uri.parse(circuitInfoUrl)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return CircuitInfo.fromJson(data);
      } else {
        debugPrint(
          'CircuitService: GET $circuitInfoUrl returned ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('CircuitService: Error fetching $circuitInfoUrl — $e');
      return null;
    }
  }

  /// Builds the MultiViewer circuit URL from [circuitKey] and [year], then
  /// delegates to [getCircuitInfo].
  @override
  Future<CircuitInfo?> getCircuitInfoByKey(int circuitKey, int year) {
    final url =
        'https://api.multiviewer.app/api/v1/circuits/$circuitKey/$year';
    return getCircuitInfo(url);
  }
}
