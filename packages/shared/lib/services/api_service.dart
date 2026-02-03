import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String? _baseUrl;

  /// Initialize API configuration
  Future<void> initApi() async {
    try {
      await dotenv.load(fileName: 'packages/shared/assets/.env');

      // Platform-specific URL handling
      // Web/Desktop -> localhost:8000
      // Android Emulator -> 10.0.2.2:8000
      if (kIsWeb) {
        // Running on web (including admin panel)
        _baseUrl = 'http://127.0.0.1:8000';
        print('🌐 Running on Web - Using 127.0.0.1:8000');
      } else {
        // Running on mobile - check if Android or iOS
        String? envUrl = dotenv.env['API_URL'];
        // Fallback to LAN IP (192.168.1.8) which is more reliable than 10.0.2.2 on some setups
        _baseUrl = envUrl ?? 'http://192.168.1.8:8000';
        print('📱 Running on Mobile - Using: $_baseUrl');
      }

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

  String get wsUrl => baseUrl.replaceFirst('http', 'ws');

  /// Resolve a potentially relative URL to an absolute one
  String resolveUrl(String? path) {
    if (path == null || path.isEmpty) return 'https://via.placeholder.com/150';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/uploads/')) return '$baseUrl$path';
    return path;
  }
}
