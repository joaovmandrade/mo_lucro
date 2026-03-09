import 'package:postgres/postgres.dart';

void main() async {
  print('Test 3: Connecting to port 5433 (Docker container)...');
  try {
    final endpoint = Endpoint(
      host: 'localhost',
      port: 15432,
      database: 'mo_lucro_db',
      username: 'postgres',
      password: 'postgres',
    );
    
    final conn = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
    
    print('Connected successfully!');
    final result = await conn.execute('SELECT 1 as test');
    print('Query result: ${result.first}');
    await conn.close();
    print('Connection closed.');
  } catch (e) {
    print('Error: $e');
  }
}
