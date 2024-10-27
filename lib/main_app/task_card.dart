import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaskCard extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onComplete,
  }) : super(key: key);

  @override
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  bool _isCompleted = false;

  void setComplete() {
    setState(() {
      _isCompleted = true;
    });
  }

  void setIncomplete() {
    setState(() {
      _isCompleted = false;
    });
  }

  String get title =>
      widget.task[dotenv.get('TASK_BODY_COLUMN')] ?? 'No Title';
  int? get points => widget.task[dotenv.get('TASK_POINT_COLUMN')];

  @override
  Widget build(BuildContext context) {
    // Theme-related variables
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Define green colors for completed state
    final completedBackgroundColor = isDarkTheme
        ? Colors.green[900]?.withOpacity(0.2) // Darker green for dark theme
        : Colors.green[50]; // Lighter green for light theme
    final completedBorderColor = Colors.green;
    final completedIconColor = Colors.green;

    // Define default colors for incomplete state
    final defaultBackgroundColor = theme.cardColor;
    final defaultBorderColor = Colors.transparent;
    final defaultIconColor = theme.iconTheme.color;

    // Determine colors based on completion status
    final cardBackgroundColor =
        _isCompleted ? completedBackgroundColor : defaultBackgroundColor;
    final borderSideColor =
        _isCompleted ? completedBorderColor : defaultBorderColor;
    final iconColor = _isCompleted ? completedIconColor : defaultIconColor;

    // Text colors
    final textColor = theme.textTheme.titleMedium?.color;
    final secondaryTextColor = theme.textTheme.bodySmall?.color;

    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: borderSideColor,
          width: 1.5,
        ),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox IconButton
            IconButton(
              onPressed: () {
                _isCompleted ? setIncomplete() : setComplete();
                widget.onComplete();
              },
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: iconColor ?? Colors.grey,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: iconColor ?? Colors.grey,
                  size: 18,
                ),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            // Title and Points
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Points: ${points ?? 0}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // More options icon
            IconButton(
              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
