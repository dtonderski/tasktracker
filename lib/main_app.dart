import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  late final SupabaseClient _supabase;
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;

    // Load initial data
    _fetchTasks(null);

    // Subscribe to real-time changes using a RealtimeChannel
    _channel = _supabase.channel('public:Test').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'Test',
        callback: (payload) { _fetchTasks(payload); }).subscribe();
  }
  
  void _fetchTasks(final PostgresChangePayload? payload) async {
    print(payload);
    final response = await _supabase.from('Test').select();
    setState(() {
      _tasks.clear();
      _tasks.addAll(response as List<Map<String, dynamic>>);
    });
  }

  @override
  void dispose() {
    // Unsubscribe from the RealtimeChannel
    _channel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Tracker')),
      body: _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index]['testtest'] ?? 'No Data'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Add a Note'),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) async {
                      await _supabase.from('Test').insert({'testtest': value});
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
