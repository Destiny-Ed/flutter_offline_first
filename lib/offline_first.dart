import 'dart:developer';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:offline_first/src/core/api_client.dart';
import 'package:offline_first/src/core/hive_storage_service.dart';
import 'package:offline_first/src/core/network_helper.dart';
import 'package:offline_first/src/data/fetch_response.dart';

enum OfflineFirstFetchPolicy { networkOnly, cacheOnly, cacheThenNetwork }

class OfflineFirst {
  final ApiClient _apiClient = ApiClient();
  final HiveStorageService _storage = HiveStorageService();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  final Set<String> _fetchingUrls = {};

  Future<FetchFirstResponse> fetchData({
    required String urlPath,
    Map<String, String>? headers,
    Duration? timeOut,
    OfflineFirstFetchPolicy fetchPolicy = OfflineFirstFetchPolicy.cacheThenNetwork,
    bool debugMode = false,
  }) async {
    try {
      if (debugMode) log("FetchPolicy: $fetchPolicy | URL: $urlPath");

      switch (fetchPolicy) {
        case OfflineFirstFetchPolicy.networkOnly:
          return await _fetchFromNetwork(urlPath, headers, timeOut, debugMode);

        case OfflineFirstFetchPolicy.cacheOnly:
          final cached = await _storage.getData(urlPath);
          if (debugMode) log("Loaded from cache (cacheOnly): $cached");

          return FetchFirstResponse(
            data: cached,
            status: cached != null,
            message: cached != null ? '' : 'No cached data found.',
          );

        case OfflineFirstFetchPolicy.cacheThenNetwork:
          final cached = await _storage.getData(urlPath);
          if (debugMode) log("Loaded from cache (cacheThenNetwork): $cached");

          _fetchFromNetwork(urlPath, headers, timeOut, debugMode); // fire & forget
          return FetchFirstResponse(
            data: cached,
            status: cached != null,
            message:
                cached != null
                    ? 'Loaded from cache. Fresh data updating in background.'
                    : 'No cached data. Fetching online...',
          );
      }
    } catch (e) {
      if (debugMode) log("Fetch error: $e");
      return FetchFirstResponse(data: null, status: false, message: e.toString());
    }
  }

  Stream<FetchFirstResponse> watchData({
    required String urlPath,
    Map<String, String>? headers,
    Duration? timeOut,
    OfflineFirstFetchPolicy fetchPolicy = OfflineFirstFetchPolicy.cacheThenNetwork,
    bool debugMode = false,
  }) async* {
    final stream = _storage.watch(urlPath);

    if ((fetchPolicy == OfflineFirstFetchPolicy.cacheThenNetwork ||
            fetchPolicy == OfflineFirstFetchPolicy.networkOnly) &&
        !_fetchingUrls.contains(urlPath)) {
      _fetchingUrls.add(urlPath);

      if (debugMode) log("Triggering network fetch in watchData() for $urlPath");

      _fetchFromNetwork(urlPath, headers, timeOut, debugMode).whenComplete(() {
        _fetchingUrls.remove(urlPath);
      });
    }

    await for (final data in stream) {
      if (debugMode) log("Stream update from cache: $data");

      yield FetchFirstResponse(
        data: data,
        status: data != null,
        message: data != null ? "Updated from cache" : "No cached data",
      );
    }
  }

  Future<void> saveData({required String key, required String content}) async {
    await _storage.saveData(key, content);
  }

  Future<FetchFirstResponse> _fetchFromNetwork(
    String urlPath,
    Map<String, String>? headers,
    Duration? timeOut,
    bool debugMode,
  ) async {
    final isConnected = await NetworkHelper.isConnected();
    if (!isConnected) {
      if (debugMode) log("No internet connection");
      return FetchFirstResponse(data: null, status: false, message: 'No internet connection.');
    }

    try {
      if (debugMode) log("Fetching from network: $urlPath");

      final data = await _apiClient.fetchData(urlPath: urlPath, headers: headers, timeOut: timeOut);
      await _storage.saveData(urlPath, data);

      if (debugMode) log("Network response saved to cache: $data");

      return FetchFirstResponse(data: data, status: true, message: 'Fetched from network.');
    } catch (e) {
      if (debugMode) log("API error: $e");
      return FetchFirstResponse(data: null, status: false, message: 'API error: $e');
    }
  }
}
