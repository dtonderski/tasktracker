import 'package:supabase_auth_ui/supabase_auth_ui.dart';

final SupabaseClient _supabase = Supabase.instance.client;

Future<String?> getUserId() async {
  final userResponse = await _supabase.auth.getUser();
  return userResponse.user?.id;
}

Future<void> logout() async {
  await _supabase.auth.signOut();
}
