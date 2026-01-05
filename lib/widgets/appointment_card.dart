import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../utils/time_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const AppointmentCard({super.key, required this.appointment, this.onCancel});

  @override
  Widget build(BuildContext context) {
    const royalBlue = Color(0xFF4169E1);
    
    // Status color mapping - all using royal blue shades
    Color statusColor;
    Color statusBgColor;
    switch (appointment.status.toLowerCase()) {
      case 'approved': 
        statusColor = Colors.green.shade600;
        statusBgColor = Colors.green.shade50;
        break;
      case 'pending': 
        statusColor = Colors.orange.shade600;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'rejected': 
        statusColor = Colors.red.shade600;
        statusBgColor = Colors.red.shade50;
        break;
      case 'completed': 
        statusColor = royalBlue;
        statusBgColor = royalBlue.withOpacity(0.1);
        break;
      case 'cancelled': 
        statusColor = Colors.grey.shade600;
        statusBgColor = Colors.grey.shade100;
        break;
      default: 
        statusColor = royalBlue;
        statusBgColor = royalBlue.withOpacity(0.1);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: royalBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: royalBlue.withOpacity(0.15), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              royalBlue.withOpacity(0.03),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: royalBlue.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: royalBlue.withOpacity(0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [royalBlue, royalBlue.withOpacity(0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.serviceType,
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 17,
                                color: royalBlue.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: #${appointment.id}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: royalBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: royalBlue.withOpacity(0.1), width: 1),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: royalBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.calendar_today, size: 16, color: royalBlue),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              appointment.date, 
                              style: const TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: royalBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.access_time, size: 16, color: royalBlue),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatTime(appointment.time), 
                              style: const TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.description_outlined, size: 18, color: royalBlue.withOpacity(0.7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            appointment.description ?? appointment.details,
                            style: TextStyle(
                              fontStyle: FontStyle.italic, 
                              color: Colors.grey.shade700, 
                              fontSize: 13, 
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (appointment.status == 'pending' && onCancel != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade50, Colors.red.shade100],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                        label: const Text(
                          "Cancel Appointment", 
                          style: TextStyle(
                            color: Colors.red, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
