import 'dart:convert';

import 'package:http/http.dart' as http;

class AppsHubClientException implements Exception {
  final String message;
  const AppsHubClientException(this.message);

  @override
  String toString() => 'AppsHubClientException: $message';
}

class AppsHubClient {
  final String baseUrl;
  final String appSlug;
  final String appToken;
  final Duration timeout;
  final http.Client _httpClient;

  AppsHubClient({
    required this.baseUrl,
    required this.appSlug,
    this.appToken = '',
    this.timeout = const Duration(seconds: 15),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Uri get bootstrapUri => Uri.parse('$baseUrl/api/v1/apps/$appSlug/bootstrap');

  Uri hubUri(String tab) => Uri.parse('$baseUrl/api/v1/apps/$appSlug/hub')
      .replace(queryParameters: <String, String>{'tab': tab});

  Future<Map<String, dynamic>> fetchBootstrap() => _getObject(bootstrapUri);
  Future<Map<String, dynamic>> fetchHub(String tab) => _getObject(hubUri(tab));

  Future<Map<String, dynamic>> _getObject(Uri uri) async {
    try {
      final response = await _httpClient.get(uri, headers: <String, String>{
        'Accept': 'application/json',
        if (appToken.trim().isNotEmpty) 'X-APP-TOKEN': appToken.trim(),
      }).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AppsHubClientException(
          'The AppsHub request failed with status ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const AppsHubClientException(
          'The AppsHub response was not a JSON object.',
        );
      }
      final root = Map<String, dynamic>.from(decoded);
      final wrapped = root['data'];
      return wrapped is Map ? Map<String, dynamic>.from(wrapped) : root;
    } on AppsHubClientException {
      rethrow;
    } on FormatException {
      throw const AppsHubClientException(
        'The AppsHub response could not be decoded.',
      );
    } catch (_) {
      throw const AppsHubClientException('AppsHub is currently unavailable.');
    }
  }

  void close() => _httpClient.close();
}
