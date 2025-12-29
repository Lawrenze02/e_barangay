import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/appointment_model.dart';

class GeminiService with ChangeNotifier {
  // NOTE: In production, this should be in an Env file or secure storage.
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
      // 1. Construct Context regarding existing slots to avoid
      final existingSlots = existingAppointments.map((a) => "${a.date} at ${a.time}").join(", ");
      
      // 2. Build Prompt
      final prompt = '''
      You are an automated scheduler for a Barangay (Community) Hall.
      A resident wants to schedule a service: "$serviceType".
      
      Existing appointments (BUSY SLOTS - DO NOT SUGGEST THESE):
      $existingSlots
      
      Your task:
      1. Suggest a realistic date and time for this appointment. 
         - Assume business hours are 8:00 AM to 5:00 PM (17:00).
         - Suggest a time at least 1 day from today (Assume today is ${DateTime.now().toString().split(' ')[0]}).
         - Do not conflict with busy slots.
      2. Generate a short, professional description for this appointment.
      
      Response Format (STRICTLY separate lines):
      DATE: YYYY-MM-DD
      TIME: HH:mm
      DESCRIPTION: [Your generated description]
      ''';

      // 3. Call API
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text;

      if (text == null) {
        throw Exception("Empty response from AI");
      }

      // 4. Parse Response
      String? date;
      String? time;
      String? description;

      final lines = text.split('\n');
      for (var line in lines) {
        if (line.trim().startsWith('DATE:')) {
          date = line.replaceAll('DATE:', '').trim();
        } else if (line.trim().startsWith('TIME:')) {
          time = line.replaceAll('TIME:', '').trim();
        } else if (line.trim().startsWith('DESCRIPTION:')) {
          description = line.replaceAll('DESCRIPTION:', '').trim();
        }
      }

      if (date != null && time != null && description != null) {
        return {
          'date': date,
          'time': time,
          'description': description,
        };
      } else {
         throw Exception("Failed to parse AI response: $text");
      }

    } catch (e) {
      print("Gemini Error: $e");
      // Fallback or rethrow
      return {
        'date': DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0], // Tomorrow
        'time': '09:00',
        'description': 'AI Service temporarily unavailable. Default slot assigned.'
      };
    }
  }
}
