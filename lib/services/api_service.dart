import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/grocery_item.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Google Apps Script web apps return a 302 to googleusercontent.com.
  /// The redirect must be followed with GET (POST to that URL fails/closes).
  Future<http.Response> _requestAppsScript({
    required String url,
    String method = 'GET',
    Map<String, dynamic>? payload,
  }) async {
    final client = http.Client();

    try {
      final request = http.Request(method, Uri.parse(url))
        ..followRedirects = false;

      if (payload != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(payload);
      }

        var streamedResponse = await client.send(request).timeout(_timeout);

      if (streamedResponse.statusCode == 302 ||
          streamedResponse.statusCode == 301 ||
          streamedResponse.statusCode == 303 ||
          streamedResponse.statusCode == 307 ||
          streamedResponse.statusCode == 308) {
        final redirectUrl = streamedResponse.headers['location'];
        await streamedResponse.stream.drain();

        if (redirectUrl == null || redirectUrl.isEmpty) {
          throw ApiException('Server redirect failed');
        }

        final redirectRequest = http.Request('GET', Uri.parse(redirectUrl));
        streamedResponse =
            await client.send(redirectRequest).timeout(_timeout);
      }

      final responseBytes = await streamedResponse.stream.toBytes();

      return http.Response.bytes(
        responseBytes,
        streamedResponse.statusCode,
        headers: streamedResponse.headers,
        request: streamedResponse.request,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } finally {
      client.close();
    }
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final trimmed = response.body.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      throw ApiException(
        'Invalid response from server. Check your Web App URL and deployment access.',
      );
    }

    return jsonDecode(trimmed) as Map<String, dynamic>;
  }

  Future<List<GroceryItem>> fetchItems() async {
    try {
      final response =
          await _requestAppsScript(url: ApiConstants.listUrl);

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to load items (status ${response.statusCode})',
        );
      }

      final body = _decodeJsonResponse(response);

      if (body['success'] != true) {
        throw ApiException(
          body['message']?.toString() ?? 'Server returned an error',
        );
      }

      final data = body['data'];
      if (data is! List) {
        throw ApiException('Invalid response format');
      }

      final items = data
          .map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
          .toList();

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('Invalid response from server');
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection and try again.',
      );
    }
  }

  Future<bool> addItem({
    required String item,
    required int quantity,
    required double cost,
    required String boughtBy,
  }) async {
    try {
      final response = await _requestAppsScript(
        url: ApiConstants.addUrl,
        method: 'POST',
        payload: {
          'item': item,
          'quantity': quantity,
          'cost': cost,
          'boughtBy': boughtBy,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to add item (status ${response.statusCode})',
        );
      }

      final body = _decodeJsonResponse(response);

      if (body['success'] != true) {
        throw ApiException(
          body['message']?.toString() ?? 'Server returned an error',
        );
      }

      return true;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('Invalid response from server');
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection and try again.',
      );
    }
  }

  Future<bool> updateItem({
    required int rowIndex,
    required String item,
    required int quantity,
    required double cost,
    required String boughtBy,
  }) async {
    try {
      final response = await _requestAppsScript(
        url: ApiConstants.updateUrl,
        method: 'POST',
        payload: {
          'rowIndex': rowIndex,
          'item': item,
          'quantity': quantity,
          'cost': cost,
          'boughtBy': boughtBy,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to update item (status ${response.statusCode})',
        );
      }

      final body = _decodeJsonResponse(response);

      if (body['success'] != true) {
        throw ApiException(
          body['message']?.toString() ?? 'Server returned an error',
        );
      }

      return true;
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('Invalid response from server');
    } catch (_) {
      throw ApiException(
        'Network error. Please check your internet connection and try again.',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
