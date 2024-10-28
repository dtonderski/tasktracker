// task_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasktracker/env.dart';
import 'package:tasktracker/services/auth_service.dart';

class PointsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = pointsTableName;

  Future<int> fetchPoints() async {
    final result = await _supabase.from(_tableName).select();
    if (result.isEmpty) {
      return 0;
    }
    assert(result.length == 1);
    return result[0]['points'];
  }

  Future<void> updatePoints(int points) async {
    final userId = await getUserId();
    await _supabase.from(_tableName).upsert(  
      {'user_id': userId, 'points': points}
    );
  }

  void subscribeToPointsChanges(
      Function(PostgresChangePayload payload) onPointsChange) {
    // Subscribe to real-time changes using a RealtimeChannel
    _supabase
        .channel('public:$_tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _tableName,
          callback: onPointsChange,
        )
        .subscribe();
  }
}
