import '../models/user_profile_model.dart';
import '../utils/api_response.dart';
import 'database_service.dart';

class PostgresBackend {
  static final PostgresBackend instance = PostgresBackend._internal();
  PostgresBackend._internal();

  String? _currentUserId;

  // ==================== Auth API ====================

  Future<ApiResponse<UserProfile>> login(String phone, String password) async {
    try {
      final db = DatabaseService.instance.connection;

      final result = await db.execute(
        'SELECT * FROM users WHERE phone = @phone LIMIT 1',
        parameters: {'phone': phone},
      );

      if (result.isEmpty) {
        return ApiResponse.error('Invalid phone number or password');
      }

      final userData = result.first.toColumnMap();
      final user = UserProfile.fromMap(userData);
      _currentUserId = user.id;

      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Login failed: $e');
    }
  }

  Future<ApiResponse<UserProfile>> registerUser(UserProfile user) async {
    try {
      final db = DatabaseService.instance.connection;

      await db.execute('''
        INSERT INTO users (
          id, name, phone, email, age, height, gender, marital_status,
          religion, caste, sub_caste, mother_tongue, gothra, kul, manglik_status,
          education, occupation, company, income, location,
          father_name, father_occupation, mother_name, mother_occupation, siblings,
          photos, bio, partner_preferences, horoscope_image_url,
          rashi, nakshatra, birth_time, birth_place, is_verified, is_premium
        ) VALUES (
          @id, @name, @phone, @email, @age, @height, @gender, @maritalStatus,
          @religion, @caste, @subCaste, @motherTongue, @gothra, @kul, @manglikStatus,
          @education, @occupation, @company, @income, @location,
          @fatherName, @fatherOccupation, @motherName, @motherOccupation, @siblings,
          @photos, @bio, @partnerPreferences, @horoscopeImageUrl,
          @rashi, @nakshatra, @birthTime, @birthPlace, @isVerified, @isPremium
        )
        ''', parameters: user.toMap());

      _currentUserId = user.id;
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Registration failed: $e');
    }
  }

  // ==================== Profile API ====================

  UserProfile? get currentUser {
    if (_currentUserId == null) return null;

    try {
      final db = DatabaseService.instance.connection;
      final result = db.execute(
        'SELECT * FROM users WHERE id = @id LIMIT 1',
        parameters: {'id': _currentUserId},
      );

      return result.then((rows) {
            if (rows.isEmpty) return null;
            return UserProfile.fromMap(rows.first.toColumnMap());
          })
          as UserProfile?;
    } catch (e) {
      return null;
    }
  }

  Future<ApiResponse<List<UserProfile>>> getAllProfiles() async {
    try {
      final db = DatabaseService.instance.connection;
      final result = await db.execute('SELECT * FROM users');

      final profiles = result
          .map((row) => UserProfile.fromMap(row.toColumnMap()))
          .toList();
      return ApiResponse.success(profiles);
    } catch (e) {
      return ApiResponse.error('Failed to fetch profiles: $e');
    }
  }

  Future<ApiResponse<UserProfile>> updateProfile(UserProfile user) async {
    try {
      final db = DatabaseService.instance.connection;

      await db.execute('''
        UPDATE users SET
          name = @name, phone = @phone, email = @email, age = @age, height = @height,
          gender = @gender, marital_status = @maritalStatus, religion = @religion,
          caste = @caste, sub_caste = @subCaste, mother_tongue = @motherTongue,
          gothra = @gothra, kul = @kul, manglik_status = @manglikStatus,
          education = @education, occupation = @occupation, company = @company,
          income = @income, location = @location, father_name = @fatherName,
          father_occupation = @fatherOccupation, mother_name = @motherName,
          mother_occupation = @motherOccupation, siblings = @siblings,
          photos = @photos, bio = @bio, partner_preferences = @partnerPreferences,
          horoscope_image_url = @horoscopeImageUrl, rashi = @rashi,
          nakshatra = @nakshatra, birth_time = @birthTime, birth_place = @birthPlace,
          is_verified = @isVerified, is_premium = @isPremium
        WHERE id = @id
        ''', parameters: user.toMap());

      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Profile update failed: $e');
    }
  }

  // ==================== Interest API ====================

  Future<ApiResponse<void>> sendInterest(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final db = DatabaseService.instance.connection;
      final interestId = 'interest_${DateTime.now().millisecondsSinceEpoch}';

      await db.execute(
        '''
        INSERT INTO interests (id, sender_id, receiver_id, status)
        VALUES (@id, @senderId, @receiverId, @status)
        ''',
        parameters: {
          'id': interestId,
          'senderId': fromUserId,
          'receiverId': toUserId,
          'status': 'pending',
        },
      );

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to send interest: $e');
    }
  }

  // ==================== Shortlist API ====================

  Future<ApiResponse<void>> toggleShortlist(
    String userId,
    String targetUserId,
  ) async {
    try {
      final db = DatabaseService.instance.connection;

      // Check if already shortlisted
      final existing = await db.execute(
        'SELECT * FROM shortlists WHERE user_id = @userId AND shortlisted_user_id = @targetUserId',
        parameters: {'userId': userId, 'targetUserId': targetUserId},
      );

      if (existing.isEmpty) {
        // Add to shortlist
        await db.execute(
          'INSERT INTO shortlists (user_id, shortlisted_user_id) VALUES (@userId, @targetUserId)',
          parameters: {'userId': userId, 'targetUserId': targetUserId},
        );
      } else {
        // Remove from shortlist
        await db.execute(
          'DELETE FROM shortlists WHERE user_id = @userId AND shortlisted_user_id = @targetUserId',
          parameters: {'userId': userId, 'targetUserId': targetUserId},
        );
      }

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to toggle shortlist: $e');
    }
  }

  Future<ApiResponse<List<UserProfile>>> getShortlisted(String userId) async {
    try {
      final db = DatabaseService.instance.connection;

      final result = await db.execute(
        '''
        SELECT u.* FROM users u
        INNER JOIN shortlists s ON u.id = s.shortlisted_user_id
        WHERE s.user_id = @userId
        ''',
        parameters: {'userId': userId},
      );

      final profiles = result
          .map((row) => UserProfile.fromMap(row.toColumnMap()))
          .toList();
      return ApiResponse.success(profiles);
    } catch (e) {
      return ApiResponse.error('Failed to fetch shortlisted profiles: $e');
    }
  }

  bool isShortlisted(String userId, String targetUserId) {
    try {
      final db = DatabaseService.instance.connection;
      final result = db.execute(
        'SELECT * FROM shortlists WHERE user_id = @userId AND shortlisted_user_id = @targetUserId',
        parameters: {'userId': userId, 'targetUserId': targetUserId},
      );

      return result.then((rows) => rows.isNotEmpty) as bool;
    } catch (e) {
      return false;
    }
  }
}
