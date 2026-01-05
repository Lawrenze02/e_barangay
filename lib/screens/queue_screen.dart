import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/appointment_model.dart';
import '../utils/time_utils.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Appointment> _queue = [];

  @override
  void initState() {
    super.initState();
    _fetchQueue();
  }

  Future<void> _fetchQueue() async {
    final apps = await _dbHelper.getFutureAppointments();
    setState(() {
      _queue = apps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchQueue,
      child: _queue.isEmpty
          ? const Center(child: Text("No upcoming appointments in queue."))
          : ListView.builder(
              itemCount: _queue.length,
              itemBuilder: (context, index) {
                final app = _queue[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(app.status),
                      child: const Icon(Icons.people, color: Colors.white, size: 20),
                    ),
                    title: Text(app.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${app.date} • ${formatTime(app.time)}"),
                    trailing: Chip(
                      label: Text(app.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      backgroundColor: _getStatusColor(app.status).withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
