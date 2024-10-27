// main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tasktracker/services/task_service.dart';
import 'task_card.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final TaskService _taskService = TaskService();
  final List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskService.fetchTasks();
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasks);
      _isLoading = false;
    });
  }

  Future<void> _addTask(String value) async {
    if (value.trim().isEmpty) return;

    final userId = await _taskService.getUserId();
    if (userId == null) {
      print('User not authenticated.');
      return;
    }

    await _taskService.addTask(value, userId);
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Tracker')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No tasks found.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskCard(
                      title: task[dotenv.get('TASK_BODY_COLUMN')] ?? 'No Data',
                      date: task['date'] ?? 'Unknown Date',
                      priority: task['priority'] ?? 'Medium',
                      category: "Meeting",
                      commentsCount: 2,
                      attachmentsCount: 5,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newTask = '';
              return AlertDialog(
                title: const Text('Add a Task'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter task description',
                  ),
                  onChanged: (value) {
                    newTask = value;
                  },
                  onSubmitted: (value) async {
                    await _addTask(value);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await _addTask(newTask);
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                    child: const Text('Add'),
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
