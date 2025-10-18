// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'YOUR KEY'; // Replace with your API key
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  static const String _systemPrompt = '''
You are EduAssist AI, a helpful assistant for the EduAssist school management platform. 

EduAssist is a comprehensive school management platform with the following features:
- Multi-role access for Students, Teachers, and School Authorities
- Assignment and Grade Management
- Real-time Notifications and Communication
- Attendance tracking
- Timetable management
- Analytics and Reports
- Secure, scalable architecture
- Modern UI with responsive design

You should help users understand:
- How to use different features
- Platform capabilities
- Navigation and functionality
- Benefits for education management
- Technical questions about the system

Keep responses helpful, concise, and focused on EduAssist. Be friendly and professional.
''';

  static Future<String> getChatResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '$_systemPrompt\n\nUser: $userMessage'
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Service Error: $e');
      return _getDefaultResponse(userMessage);
    }
  }

  static String _getDefaultResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('feature') || lowerMessage.contains('what can')) {
      return '''EduAssist offers comprehensive school management features:

📚 **For Students**: Access assignments, grades, attendance records, and timetables
👨‍🏫 **For Teachers**: Manage classes, create assignments, track student progress, and send notifications  
🏫 **For Administrators**: Oversee entire school operations, analytics, and system management

Key capabilities include real-time notifications, grade management, attendance tracking, and detailed reporting. How can I help you with a specific feature?''';
    }
    
    if (lowerMessage.contains('how to') || lowerMessage.contains('help')) {
      return '''I'm here to help you navigate EduAssist! I can assist with:

• Understanding platform features
• Navigation guidance  
• Role-specific functionality
• Technical questions
• Best practices for school management

What specific area would you like help with?''';
    }
    
    return '''Thanks for your question about EduAssist! While I'm having trouble connecting to my full knowledge base right now, I can tell you that EduAssist is designed to streamline school management with features for students, teachers, and administrators.

Feel free to explore the platform or ask me about specific features like assignments, grades, notifications, or reports!''';
  }
}
