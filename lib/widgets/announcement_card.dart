import 'package:flutter/material.dart';
import '../models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              announcement.createdAt,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const Divider(),
            Text(announcement.content),
          ],
        ),
      ),
    );
  }
}
