// main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:tasktracker/extensions.dart';
import 'package:tasktracker/services/auth_service.dart';
import 'package:tasktracker/services/points_service.dart';
import 'package:tasktracker/services/task_service.dart';
import 'task_card.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final TaskService _taskService = TaskService();
  final PointsService _pointsService = PointsService();
  final List<Map<String, dynamic>> _tasks = [];
  final Map<String, GlobalKey<TaskCardState>> _taskCardKeys = {};
  bool _isLoading = true;

  // Added for theme management
  ThemeMode _themeMode = ThemeMode.light;

  // Total points (hardcoded for now)
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _fetchPoints();
    _taskService.subscribeToTaskChanges(_updateTasks);
    _pointsService.subscribeToPointsChanges(_updatePoints);
  }

  void _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskService.fetchTasks();
    setState(() {
      _tasks.clear();
      _taskCardKeys.clear();
      _tasks.addAll(tasks);

      for (var task in tasks) {
        _taskCardKeys[task['id']] = GlobalKey<TaskCardState>();
      }
      _isLoading = false;
    });
  }

  void _fetchPoints() async {
    int points = await _pointsService.fetchPoints();

    setState(() {
      _totalPoints = points;
    });
  }

  void _updateTasks(final PostgresChangePayload? payload) async {
    if (payload == null) {
      return;
    }

    setState(() {
      switch (payload.eventType) {
        case PostgresChangeEvent.all:
          _fetchTasks();
          break;
        case PostgresChangeEvent.insert:
          _tasks.add(payload.newRecord);
          break;
        case PostgresChangeEvent.update:
          final index = _tasks
              .indexWhere((entry) => entry['id'] == payload.oldRecord['id']);
          if (index != -1) {
            _tasks[index] = payload.newRecord;
          }
          break;
        case PostgresChangeEvent.delete:
          _tasks.removeWhere((entry) => entry['id'] == payload.oldRecord['id']);
          break;
      }
    });
  }

  void _updatePoints(final PostgresChangePayload? payload) async {
    if (payload == null) {
      return;
    }

    setState(() {
      switch (payload.eventType) {
        case PostgresChangeEvent.all:
          _fetchPoints();
          break;
        case PostgresChangeEvent.insert:
          _totalPoints = payload.newRecord['points'];
          break;
        case PostgresChangeEvent.update:
          _totalPoints = payload.newRecord['points'];
          break;
        case PostgresChangeEvent.delete:
          _totalPoints = 0;
          break;
      }
    });
  }

  void _handleCompleteTask(Map<String, dynamic> task) {
    // Perform checks and update state here
    const shouldCompleteTask = true; // Replace with your actual condition logic
    String taskId = task['id'];
    int taskPoints = task['points'];

    if (shouldCompleteTask) {
      // If the task should be marked as complete, call setComplete on the TaskCard
      _taskCardKeys[taskId]?.currentState?.setComplete();
      context.showSnackBar(
          "Completed ${task['body']} - you gained $taskPoints points!");
      setState(() {
        _totalPoints += taskPoints;
      });
      _pointsService.updatePoints(_totalPoints);
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Add logout function
  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    context.showSnackBar('Logged out successfully');
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Theme to toggle between light and dark themes
    return Theme(
      data:
          _themeMode == ThemeMode.light ? ThemeData.light() : ThemeData.dark(),
      child: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Task Tracker'),
            actions: [
              // Total Points
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Points: $_totalPoints'),
                ),
              ),
              // Theme Selector
              IconButton(
                icon: Icon(_themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: _toggleTheme,
              ),
              // Logout Button
              TextButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Daily Tasks'),
                Tab(text: 'Rewards'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // First tab content (Daily Tasks)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(child: Text('No tasks found.'))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final taskId = task['id'];
                            final taskKey = _taskCardKeys[taskId];

                            return TaskCard(
                              key: taskKey,
                              task: task,
                              onComplete: () => _handleCompleteTask(task),
                            );
                          },
                        ),
              // Second tab content (Rewards)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rewards',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                int pointsToRedeem = 0;
                                final _formKey = GlobalKey<FormState>();
                                return AlertDialog(
                                  title: const Text('Redeem Points'),
                                  content: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Task Description Field
                                          TextFormField(
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              labelText: 'Points to Redeem',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              pointsToRedeem =
                                                  int.tryParse(value) ?? 0;
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Please enter the number of points to redeem';
                                              }
                                              if (int.tryParse(value) == null) {
                                                return 'Please enter a valid number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    // Cancel Button
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    // Redeem Button
                                    TextButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          await _redeemPoints(pointsToRedeem);
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                      },
                                      child: const Text('Redeem'),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Text("Redeem Points")),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton(
                onPressed: () {
                  if (DefaultTabController.of(context).index == 0) {
                    // Only show the dialog if on the Daily Tasks tab
                    showDialog(
                      context: context,
                      builder: (context) {
                        String newTask = '';
                        int taskPoints = 0;
                        final formKey = GlobalKey<FormState>();
                        return AlertDialog(
                          title: const Text('Add a Task'),
                          content: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Task Description Field
                                  TextFormField(
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Task Description',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      newTask = value;
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a task description';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Task Points Field
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Points',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      taskPoints = int.tryParse(value) ?? 0;
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter the number of points';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            // Cancel Button
                            TextButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                              },
                              child: const Text('Cancel'),
                            ),
                            // Add Button
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  await _addTask(newTask, taskPoints);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog');
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Icon(Icons.add),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addTask(String value, int points) async {
    if (value.trim().isEmpty) return;

    final userId = await getUserId();
    if (userId == null) {
      print('User not authenticated.');
      return;
    }

    await _taskService.addTask(value, userId, points);
  }

  Future<void> _redeemPoints(int points) async {
    final userId = await getUserId();
    if (userId == null) {
      print('User not authenticated.');
      return;
    }
    setState(() {
      _totalPoints -= points;
    });
    await _pointsService.updatePoints(_totalPoints);
  }
}
