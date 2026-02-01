import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Connection? _connection;

  /// Initialize database connection and create tables if they don't exist
  Future<void> initDatabase() async {
    try {
      await dotenv.load(fileName: 'packages/shared/.env');

      final endpoint = Endpoint(
        host: dotenv.env['DB_HOST'] ?? 'localhost',
        port: int.parse(dotenv.env['DB_PORT'] ?? '5432'),
        database: dotenv.env['DB_NAME'] ?? 'mali_matrimony_database_dev_stage',
        username: dotenv.env['DB_USER'] ?? 'postgres',
        password: dotenv.env['DB_PASSWORD'] ?? '',
      );

      _connection = await Connection.open(
        endpoint,
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      print('✅ Database connected successfully!');

      // Create tables if they don't exist
      await _createTables();
    } catch (e) {
      print('❌ Database connection failed: $e');
      rethrow;
    }
  }

  /// Get active database connection
  Connection get connection {
    if (_connection == null) {
      throw Exception('Database not initialized. Call initDatabase() first.');
    }
    return _connection!;
  }

  /// Create all necessary tables
  Future<void> _createTables() async {
    try {
      // Users table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id VARCHAR(255) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          phone VARCHAR(20) UNIQUE,
          email VARCHAR(255),
          age INTEGER NOT NULL,
          height DOUBLE PRECISION NOT NULL,
          gender VARCHAR(20) NOT NULL,
          marital_status VARCHAR(50) NOT NULL,
          religion VARCHAR(100) NOT NULL,
          caste VARCHAR(100) NOT NULL,
          sub_caste VARCHAR(100) NOT NULL,
          mother_tongue VARCHAR(100) NOT NULL,
          gothra VARCHAR(100),
          kul VARCHAR(100),
          manglik_status VARCHAR(50),
          education VARCHAR(255),
          occupation VARCHAR(255),
          company VARCHAR(255),
          income VARCHAR(100),
          location VARCHAR(255),
          father_name VARCHAR(255),
          father_occupation VARCHAR(255),
          mother_name VARCHAR(255),
          mother_occupation VARCHAR(255),
          siblings INTEGER DEFAULT 0,
          photos TEXT[],
          bio TEXT,
          partner_preferences TEXT,
          horoscope_image_url TEXT,
          rashi VARCHAR(100),
          nakshatra VARCHAR(100),
          birth_time VARCHAR(50),
          birth_place VARCHAR(255),
          is_verified BOOLEAN DEFAULT FALSE,
          is_premium BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      // Interests table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS interests (
          id VARCHAR(255) PRIMARY KEY,
          sender_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
          receiver_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
          status VARCHAR(50) NOT NULL,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      // Shortlists table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS shortlists (
          user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
          shortlisted_user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (user_id, shortlisted_user_id)
        );
      ''');

      print('✅ Database tables created successfully!');
    } catch (e) {
      print('❌ Table creation failed: $e');
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
