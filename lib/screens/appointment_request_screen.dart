import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../data/db_helper.dart';
import '../models/appointment_model.dart';

class AppointmentRequestScreen extends StatefulWidget {
  const AppointmentRequestScreen({super.key});

  @override
  State<AppointmentRequestScreen> createState() => _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  final List<String> _serviceTypes = [
    'Barangay Clearance',
    'Certificate of Residency',
    'Certificate of Indigency',
    'Business Permit',
    'Complaint / Blotter',
    'Other',
  ];
  String? _selectedService;
  bool _isLoading = false;
  Map<String, String>? _generatedSchedule;

  void _generateSchedule() async {
    if (_selectedService == null) return;

    setState(() => _isLoading = true);
    try {
      final geminiService = Provider.of<GeminiService>(context, listen: false);
      final dbHelper = DBHelper();
      
      // Fetch all appointments to pass as context (naive approach, better to fetch range)
      final allApps = await dbHelper.getAllAppointments();

      final result = await geminiService.suggestAppointment(
        serviceType: _selectedService!,
        existingAppointments: allApps,
      );

      setState(() {
        _generatedSchedule = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmAppointment() async {
    if (_generatedSchedule == null) return;

    setState(() => _isLoading = true);
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    final appointment = Appointment(
      userId: user.id!,
      serviceType: _selectedService!,
      date: _generatedSchedule!['date']!,
      time: _generatedSchedule!['time']!,
      status: 'pending',
      details: 'Scheduled via Gemini AI',
      description: _generatedSchedule!['description'],
    );

    await DBHelper().insertAppointment(appointment);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment Request Sent!')),
      );
      Navigator.pop(context, true); // Return true to refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Select Service:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedService,
              isExpanded: true,
              hint: const Text("Choose service..."),
              items: _serviceTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() {
                 _selectedService = val;
                 _generatedSchedule = null; // Reset if service changes
              }),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: (_selectedService != null && !_isLoading) ? _generateSchedule : null,
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.auto_awesome),
              label: const Text("Ask Gemini AI for Schedule"),
            ),
            if (_generatedSchedule != null) ...[
              const Divider(height: 32),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("AI Suggested Schedule:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                      const SizedBox(height: 8),
                      Text("Date: ${_generatedSchedule!['date']}", style: const TextStyle(fontSize: 18)),
                      Text("Time: ${_generatedSchedule!['time']}", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("Note: ${_generatedSchedule!['description']}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _confirmAppointment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("Confirm Appointment"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
