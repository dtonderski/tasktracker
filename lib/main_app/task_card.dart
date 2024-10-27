// task_card.dart
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String date;
  final String priority;
  final String category;
  final int commentsCount;
  final int attachmentsCount;

  const TaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.priority,
    required this.category,
    required this.commentsCount,
    required this.attachmentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Add options like edit, delete here
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildBadge(priority, Colors.pink),
                const SizedBox(width: 8),
                _buildBadge(category, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    const Icon(Icons.comment, size: 18),
                    const SizedBox(width: 4),
                    Text("$commentsCount"),
                    const SizedBox(width: 16),
                    const Icon(Icons.attach_file, size: 18),
                    const SizedBox(width: 4),
                    Text("$attachmentsCount"),
                    const SizedBox(width: 16),
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 12,
                      child: Text(
                        "A",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 12,
                      child: Text(
                        "B",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
