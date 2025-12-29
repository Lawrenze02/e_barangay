import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (appointment.status.toLowerCase()) {
      case 'approved': statusColor = Colors.green; break;
      case 'pending': statusColor = Colors.orange; break;
      case 'rejected': statusColor = Colors.red; break;
      case 'completed': statusColor = Colors.blue; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceType,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Expanded(
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Date: ${appointment.date}"),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Time: ${appointment.time}"),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Description: ${appointment.description ?? appointment.details}",
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
