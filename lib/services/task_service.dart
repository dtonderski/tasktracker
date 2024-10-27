// task_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = dotenv.get('TASKS_TABLE_NAME');

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await _supabase.from(_tableName).select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addTask(String value, String userId, int points) async {
    await _supabase.from(_tableName).insert({
      dotenv.get('TASK_BODY_COLUMN'): value,
      'user_id': userId,
      'points': points
    });
  }


  // Set up a subscription to listen for real-time changes in the tasks table
  void subscribeToTaskChanges(
      Function(PostgresChangePayload payload) onTaskChange) {
    // Subscribe to real-time changes using a RealtimeChannel
    _supabase
        .channel('public:${_tableName}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _tableName,
          callback: onTaskChange,
        )
        .subscribe();
  }
}
