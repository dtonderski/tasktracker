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

  Future<void> addTask(String value, String userId) async {
    await _supabase.from(_tableName).insert({
      dotenv.get('TASK_BODY_COLUMN'): value,
      'user_id': userId,
    });
  }

  Future<String?> getUserId() async {
    final userResponse = await _supabase.auth.getUser();
    return userResponse.user?.id;
  }
}