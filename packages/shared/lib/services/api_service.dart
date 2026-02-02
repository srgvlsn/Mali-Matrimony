import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String? _baseUrl;

  /// Initialize API configuration
  Future<void> initApi() async {
    try {
      await dotenv.load(fileName: 'packages/shared/assets/.env');

      // Use API_URL from .env or fallback to localhost
      _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';

      print('✅ API Service initialized with base URL: $_baseUrl');
    } catch (e) {
      print('❌ API Service initialization failed: $e');
      rethrow;
    }
  }

  /// Get base URL
  String get baseUrl {
    if (_baseUrl == null) {
      throw Exception('ApiService not initialized. Call initApi() first.');
    }
    return _baseUrl!;
  }

  /// Resolve a potentially relative URL to an absolute one
  String resolveUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/150';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/uploads/')) return '$baseUrl$path';
    return path;
  }
}
