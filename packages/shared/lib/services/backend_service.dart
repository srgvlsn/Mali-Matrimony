import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';
import '../models/interest_model.dart';
import '../utils/api_response.dart';
import 'api_service.dart';

class BackendService {
  static final BackendService instance = BackendService._internal();
  BackendService._internal();

  UserProfile? _currentUser;

  String get _baseUrl => ApiService.instance.baseUrl;

  // ==================== Auth API ====================

  Future<ApiResponse<UserProfile>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login?phone=$phone'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final user = UserProfile.fromMap(data['data']);
        _currentUser = user;
        return ApiResponse.success(user);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Login failed: $e');
    }
  }

  Future<ApiResponse<UserProfile>> registerUser(UserProfile user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toMap()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final registeredUser = UserProfile.fromMap(data['data']);
        _currentUser = registeredUser;
        return ApiResponse.success(registeredUser);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      return ApiResponse.error('Registration failed: $e');
    }
  }

  // ==================== Profile API ====================

  UserProfile? get currentUser => _currentUser;

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profiles/${_currentUser!.id}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _currentUser = UserProfile.fromMap(data['data']);
      }
    } catch (e) {
      print('Failed to refresh current user: $e');
    }
  }

  void logout() {
    _currentUser = null;
  }

  Future<ApiResponse<List<UserProfile>>> getAllProfiles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/profiles'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> profilesJson = data['data'];
        final profiles = profilesJson
            .map((p) => UserProfile.fromMap(p))
            .toList();
        return ApiResponse.success(profiles);
      } else {
        return ApiResponse.error('Failed to fetch profiles');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch profiles: $e');
    }
  }

  Future<ApiResponse<void>> updateProfile(UserProfile user) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profiles/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toMap()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final updatedUser = UserProfile.fromMap(data['data']);
        if (_currentUser?.id == updatedUser.id) {
          _currentUser = updatedUser;
        }
        return ApiResponse.success(null);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['detail'] ?? 'Profile update failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Profile update failed: $e');
    }
  }

  Future<ApiResponse<void>> deleteProfile(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/profiles/$userId'),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['detail'] ?? 'Profile deletion failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Profile deletion failed: $e');
    }
  }

  // ==================== Interest API ====================

  Future<ApiResponse<void>> sendInterest(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final interestId = 'interest_${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.post(
        Uri.parse('$_baseUrl/interests'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': interestId,
          'sender_id': fromUserId,
          'receiver_id': toUserId,
          'status': 'pending',
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to send interest');
      }
    } catch (e) {
      return ApiResponse.error('Failed to send interest: $e');
    }
  }

  Future<ApiResponse<void>> updateInterestStatus(
    String interestId,
    InterestStatus status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/interests/$interestId?status=${status.name}'),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['detail'] ?? 'Failed to update interest status',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to update interest status: $e');
    }
  }

  Future<ApiResponse<List<InterestModel>>> getInterests(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/interests/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> interestsJson = data['data'];
        final interests = interestsJson
            .map((i) => InterestModel.fromMap(i))
            .toList();
        return ApiResponse.success(interests);
      } else {
        return ApiResponse.error('Failed to fetch interests');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch interests: $e');
    }
  }

  // ==================== Shortlist API ====================

  Future<ApiResponse<void>> toggleShortlist(
    String userId,
    String targetUserId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/shortlists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'shortlisted_user_id': targetUserId,
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to toggle shortlist');
      }
    } catch (e) {
      return ApiResponse.error('Failed to toggle shortlist: $e');
    }
  }

  Future<ApiResponse<List<UserProfile>>> getShortlisted(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shortlists/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> profilesJson = data['data'];
        final profiles = profilesJson
            .map((p) => UserProfile.fromMap(p))
            .toList();
        return ApiResponse.success(profiles);
      } else {
        return ApiResponse.error('Failed to fetch shortlisted profiles');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch shortlisted profiles: $e');
    }
  }
}
