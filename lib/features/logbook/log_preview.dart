import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';

class LogPreviewPage extends StatelessWidget {
  final LogModel log;

  const LogPreviewPage({super.key, required this.log});

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Task":
        return Colors.green;
      case "Information":
        return Colors.blue;
      case "Bug":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Catatan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    log.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Chip(
                  label: Text(log.category),
                  backgroundColor: _getCategoryColor(log.category),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Markdown(
                data: log.description,
                selectable: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}