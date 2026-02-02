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

  Future<ApiResponse<UserProfile>> login(
    String phone, {
    String? password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password ?? ''}),
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

  Future<ApiResponse<Map<String, dynamic>>> adminLogin(
    String username,
    String password,
  ) async {
    try {
      print('🚀 Requesting Admin Login: $_baseUrl/admin/login');
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      print('📥 Admin Login Response Code: ${response.statusCode}');
      print('📥 Admin Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.success(data['data']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Admin login failed');
      }
    } catch (e) {
      return ApiResponse.error('Admin login failed: $e');
    }
  }

  Future<ApiResponse<UserProfile>> registerUser(
    UserProfile user, {
    String? password,
  }) async {
    try {
      final userMap = user.toMap();
      if (password != null) {
        userMap['password'] = password;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userMap),
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

  Future<ApiResponse<bool>> requestOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(
          errorData['detail'] ?? 'Failed to request OTP',
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to request OTP: $e');
    }
  }

  Future<ApiResponse<UserProfile>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final user = UserProfile.fromMap(data['data']);
        _currentUser = user;
        return ApiResponse.success(user);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Invalid OTP');
      }
    } catch (e) {
      return ApiResponse.error('OTP verification failed: $e');
    }
  }

  // ==================== Analytics API ====================

  Future<ApiResponse<Map<String, dynamic>>> getAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/analytics'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Failed to fetch analytics');
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch analytics: $e');
    }
  }

  // ==================== Profile API ====================

  UserProfile? get currentUser => _currentUser;

  Future<ApiResponse<String>> uploadImage(
    List<int> bytes,
    String filename,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ApiResponse.success(data['data']['url']);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return ApiResponse.error(errorData['detail'] ?? 'Upload failed');
      }
    } catch (e) {
      return ApiResponse.error('Upload failed: $e');
    }
  }

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

  // ==================== Photo Management ====================

  Future<ApiResponse<void>> updateProfilePhoto(
    List<int> bytes,
    String filename,
  ) async {
    if (_currentUser == null) return ApiResponse.error('Not logged in');

    final uploadResponse = await uploadImage(bytes, filename);
    final url = uploadResponse.data;
    if (!uploadResponse.success || url == null) {
      return ApiResponse.error(uploadResponse.message ?? 'Upload failed');
    }

    final List<String> updatedPhotos = List<String>.from(_currentUser!.photos);
    if (updatedPhotos.isEmpty) {
      updatedPhotos.add(url);
    } else {
      updatedPhotos[0] = url;
    }

    final updatedProfile = _currentUser!.copyWith(photos: updatedPhotos);
    final response = await updateProfile(updatedProfile);

    if (response.success) {
      _currentUser = updatedProfile;
    }
    return response;
  }

  Future<ApiResponse<void>> addAdditionalPhoto(
    List<int> bytes,
    String filename,
  ) async {
    if (_currentUser == null) return ApiResponse.error('Not logged in');

    // Limit: 1 main + 3 additional = 4 total
    if (_currentUser!.photos.length >= 4) {
      return ApiResponse.error('Maximum 4 photos allowed');
    }

    final uploadResponse = await uploadImage(bytes, filename);
    final url = uploadResponse.data;
    if (!uploadResponse.success || url == null) {
      return ApiResponse.error(uploadResponse.message ?? 'Upload failed');
    }

    final updatedPhotos = List<String>.from(_currentUser!.photos)..add(url);
    final updatedProfile = _currentUser!.copyWith(photos: updatedPhotos);

    final response = await updateProfile(updatedProfile);
    if (response.success) {
      _currentUser = updatedProfile;
    }
    return response;
  }

  Future<ApiResponse<void>> removePhoto(int index) async {
    if (_currentUser == null || index >= _currentUser!.photos.length) {
      return ApiResponse.error('Invalid operation');
    }

    final updatedPhotos = List<String>.from(_currentUser!.photos)
      ..removeAt(index);
    final updatedProfile = _currentUser!.copyWith(photos: updatedPhotos);

    final response = await updateProfile(updatedProfile);
    if (response.success) {
      _currentUser = updatedProfile;
    }
    return response;
  }

  Future<ApiResponse<void>> uploadHoroscope(
    List<int> bytes,
    String filename,
  ) async {
    if (_currentUser == null) return ApiResponse.error('Not logged in');

    final uploadResponse = await uploadImage(bytes, filename);
    final url = uploadResponse.data;
    if (!uploadResponse.success || url == null) {
      return ApiResponse.error(uploadResponse.message ?? 'Upload failed');
    }

    final updatedProfile = _currentUser!.copyWith(horoscopeImageUrl: url);
    final response = await updateProfile(updatedProfile);

    if (response.success) {
      _currentUser = updatedProfile;
    }
    return response;
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
