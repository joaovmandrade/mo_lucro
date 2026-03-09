import 'package:postgres/postgres.dart';
import 'config.dart';

/// PostgreSQL database connection manager.
class Database {
  static Connection? _connection;

  /// Get or create database connection.
  static Future<Connection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await _createConnection();
    return _connection!;
  }

  static Future<Connection> _createConnection() async {
    final endpoint = Endpoint(
      host: AppConfig.dbHost,
      port: AppConfig.dbPort,
      database: AppConfig.dbName,
      username: AppConfig.dbUser,
      password: AppConfig.dbPassword,
    );

    final conn = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    print('[Database] Connected to PostgreSQL at '
        '${AppConfig.dbHost}:${AppConfig.dbPort}/${AppConfig.dbName}');

    return conn;
  }

  /// Execute a query and return results.
  static Future<Result> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final conn = await connection;
    return conn.execute(
      Sql.named(sql),
      parameters: parameters ?? {},
    );
  }

  /// Close the connection.
  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
    print('[Database] Connection closed');
  }
}
