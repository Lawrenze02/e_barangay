import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/appointment_model.dart';

class GeminiService with ChangeNotifier {
  
  static const String _apiKey = 'AIzaSyDxV4kuqOvqc_QNi0Ik73YSUdAd4xBFHEo';
  
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }

  Future<Map<String, String>> suggestAppointment({
    required String serviceType,
    required List<Appointment> existingAppointments,
  }) async {
    try {
      final now = DateTime.now();
      // Filter context to future only for efficiency
      final futureApps = existingAppointments.where((a) {
        try {
          final appDate = DateTime.parse(a.date);
          return appDate.isAfter(now.subtract(const Duration(days: 1)));
        } catch (_) { return false; }
      }).toList();

      final existingSlots = futureApps.map((a) => "${a.date} ${a.time}").join(", ");
      final todayStr = now.toString().split(' ')[0];
      
      final prompt = '''
      role: Barangay Scheduler
      current_date: "$todayStr"
      task: Schedule "$serviceType"
      busy_slots: [$existingSlots]
      
      rules:
      1. Next available 30-min slot.
      2. Hours: 08:00-17:00. M-F only.
      3. Start DATE must be TOMORROW or later.
      4. STRICT json output.
      
      json_format:
      {
        "date": "YYYY-MM-DD",
        "time": "HH:mm",
        "description": "Professional description"
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text;

      if (text == null) throw Exception("Empty AI response");

      // Robust JSON Extraction
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
      if (jsonMatch == null) throw Exception("No JSON found in response");
      
      final jsonStr = jsonMatch.group(0)!;
      final Map<String, dynamic> jsonResponse = jsonDecode(jsonStr);
      
      return {
        'date': jsonResponse['date']?.toString() ?? '',
        'time': jsonResponse['time']?.toString() ?? '',
        'description': jsonResponse['description']?.toString() ?? '',
      };

    } catch (e) {
      print("Gemini Error: $e");
      // Fallback: Local algorithm to find next free slot
      return _findNextAvailableSlot(existingAppointments, serviceType);
    }
  }

  Map<String, String> _findNextAvailableSlot(List<Appointment> existingApps, String serviceType) {
    // Start searching from tomorrow 8am
    var checkDate = DateTime.now().add(const Duration(days: 1));
    // Reset to 8:00 AM
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day, 8, 0);

    // Limit search to 14 days to prevent infinite loops
    for (int i = 0; i < 14; i++) {
        // Skip weekends
        if (checkDate.weekday == DateTime.saturday || checkDate.weekday == DateTime.sunday) {
            checkDate = checkDate.add(const Duration(days: 1));
            checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day, 8, 0);
            continue;
        }

        // Check slots 8am to 5pm (17:00)
        while (checkDate.hour < 17) {
            final dateStr = checkDate.toString().split(' ')[0];
            final timeStr = "${checkDate.hour.toString().padLeft(2, '0')}:${checkDate.minute.toString().padLeft(2, '0')}";
            
            // Check conflict
            bool isBusy = existingApps.any((app) => app.date == dateStr && app.time == timeStr && app.status != 'rejected');

            if (!isBusy) {
                return {
                    'date': dateStr,
                    'time': timeStr,
                    'description': 'Confirmed appointment for $serviceType'
                };
            }
            // Increment by 30 mins
            checkDate = checkDate.add(const Duration(minutes: 30));
        }
        
        // Move to next day 8am
        checkDate = checkDate.add(const Duration(days: 1));
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day, 8, 0);
    }
    
    // Ultimate fallback if fully booked for 2 weeks
    return {
        'date': DateTime.now().add(const Duration(days: 3)).toString().split(' ')[0],
        'time': '08:00',
        'description': 'Confirmed appointment for $serviceType (High Congestion)'
    };
  }
}
