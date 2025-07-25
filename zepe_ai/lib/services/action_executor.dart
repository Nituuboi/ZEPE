import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/intent_model.dart';
import '../utils/math_calculator.dart';

class ActionExecutor {
  static final ActionExecutor _instance = ActionExecutor._internal();
  factory ActionExecutor() => _instance;
  ActionExecutor._internal();

  final MathCalculator _calculator = MathCalculator();

  Future<String> executeAction(Intent intent) async {
    try {
      switch (intent.type) {
        case IntentType.greeting:
          return _handleGreeting(intent);
        
        case IntentType.farewell:
          return _handleFarewell(intent);
        
        case IntentType.appLaunch:
          return await _handleAppLaunch(intent);
        
        case IntentType.webSearch:
          return await _handleWebSearch(intent);
        
        case IntentType.timeQuery:
          return _handleTimeQuery(intent);
        
        case IntentType.weatherQuery:
          return _handleWeatherQuery(intent);
        
        case IntentType.systemControl:
          return await _handleSystemControl(intent);
        
        case IntentType.phoneCall:
          return await _handlePhoneCall(intent);
        
        case IntentType.textMessage:
          return await _handleTextMessage(intent);
        
        case IntentType.reminder:
          return _handleReminder(intent);
        
        case IntentType.calendar:
          return _handleCalendar(intent);
        
        case IntentType.calculation:
          return _handleCalculation(intent);
        
        case IntentType.question:
          return _handleQuestion(intent);
        
        default:
          return _handleUnknown(intent);
      }
    } catch (e) {
      debugPrint('Error executing action: $e');
      return "I encountered an error while trying to do that. Please try again.";
    }
  }

  String _handleGreeting(Intent intent) {
    List<String> responses = [
      "Hello! I'm ZEPE, your superhuman voice assistant. How can I help you today?",
      "Hi there! Ready to make your phone do amazing things with just your voice?",
      "Hey! ZEPE here - I can control your apps, search the web, and much more. What do you need?",
      "Good to hear from you! I'm here to help with anything you need.",
    ];
    
    // Add time-based greetings
    int hour = DateTime.now().hour;
    if (hour < 12) {
      responses.add("Good morning! How can I assist you today?");
    } else if (hour < 17) {
      responses.add("Good afternoon! What can I help you with?");
    } else {
      responses.add("Good evening! Ready to get things done?");
    }
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _handleFarewell(Intent intent) {
    List<String> responses = [
      "Goodbye! Feel free to call on me anytime you need assistance.",
      "See you later! I'll be here whenever you need me.",
      "Until next time! Remember, I never sleep - just say my name!",
      "Take care! I'm always ready to help when you need me.",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }

  Future<String> _handleAppLaunch(Intent intent) async {
    String appName = intent.parameters['appName'] ?? '';
    
    if (appName.isEmpty) {
      return "Which app would you like me to open?";
    }

    try {
      // Try common app package names with Android Intent
      Map<String, String> commonApps = {
        'youtube': 'com.google.android.youtube',
        'chrome': 'com.android.chrome',
        'gmail': 'com.google.android.gm',
        'whatsapp': 'com.whatsapp',
        'instagram': 'com.instagram.android',
        'facebook': 'com.facebook.katana',
        'spotify': 'com.spotify.music',
        'netflix': 'com.netflix.mediaclient',
        'maps': 'com.google.android.apps.maps',
        'camera': 'com.android.camera2',
        'gallery': 'com.google.android.apps.photos',
        'settings': 'com.android.settings',
        'calculator': 'com.android.calculator2',
        'calendar': 'com.google.android.calendar',
        'clock': 'com.google.android.deskclock',
        'contacts': 'com.android.contacts',
        'phone': 'com.android.dialer',
        'messages': 'com.google.android.apps.messaging',
      };

      String? packageName = commonApps[appName.toLowerCase()];
      if (packageName != null) {
        // Use url_launcher to launch apps
        Uri appUri = Uri.parse('$packageName://');
        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri);
          return "Opening $appName for you.";
        } else {
          return "I found $appName but couldn't open it. Please make sure it's installed.";
        }
      }

      return "I couldn't find an app called '$appName'. I can open: ${commonApps.keys.join(', ')}.";
    } catch (e) {
      debugPrint('Error launching app: $e');
      return "I had trouble opening that app. Please make sure it's installed and try again.";
    }
  }

  Future<String> _handleWebSearch(Intent intent) async {
    String query = intent.parameters['query'] ?? '';
    
    if (query.isEmpty) {
      return "What would you like me to search for?";
    }

    try {
      String searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
      Uri uri = Uri.parse(searchUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return "Searching for '$query' on Google.";
      } else {
        return "I couldn't open the browser to search for that.";
      }
    } catch (e) {
      debugPrint('Error performing web search: $e');
      return "I had trouble performing that search. Please try again.";
    }
  }

  String _handleTimeQuery(Intent intent) {
    DateTime now = DateTime.now();
    String timeFormat = DateFormat('h:mm a').format(now);
    String dateFormat = DateFormat('EEEE, MMMM d').format(now);
    
    return "It's currently $timeFormat on $dateFormat.";
  }

  String _handleWeatherQuery(Intent intent) {
    // For now, return a placeholder response
    // In a real implementation, you'd integrate with a weather API
    return "I'd love to tell you about the weather, but I need to connect to a weather service first. This feature is coming soon!";
  }

  Future<String> _handleSystemControl(Intent intent) async {
    String action = intent.parameters['action'] ?? '';
    String target = intent.parameters['target'] ?? '';

    if (target.isEmpty) {
      return "What system setting would you like me to control?";
    }

    try {
      switch (target) {
        case 'wifi':
          return await _controlWifi(action);
        case 'bluetooth':
          return await _controlBluetooth(action);
        case 'airplane_mode':
          return await _controlAirplaneMode(action);
        case 'volume':
          return _controlVolume(action);
        case 'brightness':
          return _controlBrightness(action);
        default:
          return "I can control WiFi, Bluetooth, airplane mode, volume, and brightness. What would you like me to adjust?";
      }
    } catch (e) {
      debugPrint('Error controlling system: $e');
      return "I had trouble adjusting that setting. Some system controls require special permissions.";
    }
  }

  Future<String> _controlWifi(String action) async {
    try {
      Uri settingsUri = Uri.parse('android.settings.WIFI_SETTINGS://');
      if (await canLaunchUrl(settingsUri)) {
        await launchUrl(settingsUri);
        return "Opening WiFi settings for you.";
      } else {
        return "I can help you access WiFi settings. Please open Settings > Network & Internet > Wi-Fi manually.";
      }
    } catch (e) {
      return "I can help you access WiFi settings. Please open Settings > Network & Internet > Wi-Fi manually.";
    }
  }

  Future<String> _controlBluetooth(String action) async {
    return "To control Bluetooth, please open Settings > Connected devices > Bluetooth manually. System control features are coming soon!";
  }

  Future<String> _controlAirplaneMode(String action) async {
    return "To control airplane mode, please swipe down from the top of your screen and tap the airplane icon. System control features are coming soon!";
  }

  String _controlVolume(String action) {
    // Volume control would require platform-specific implementation
    return "To adjust volume, please use your device's volume buttons or settings.";
  }

  String _controlBrightness(String action) {
    // Brightness control would require platform-specific implementation
    return "To adjust brightness, please swipe down from the top of your screen and use the brightness slider.";
  }

  Future<String> _handlePhoneCall(Intent intent) async {
    String contact = intent.parameters['contact'] ?? '';
    String phoneNumber = intent.parameters['phoneNumber'] ?? '';

    if (contact.isEmpty && phoneNumber.isEmpty) {
      return "Who would you like me to call?";
    }

    try {
      if (phoneNumber.isNotEmpty) {
        Uri uri = Uri.parse('tel:$phoneNumber');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return "Calling $phoneNumber.";
        }
      } else {
        return "I found the contact '$contact'. To call them, please say their phone number or ask me to open your contacts.";
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
    }

    return "I had trouble making that call. Please try again.";
  }

  Future<String> _handleTextMessage(Intent intent) async {
    String contact = intent.parameters['contact'] ?? '';
    String message = intent.parameters['message'] ?? '';

    if (contact.isEmpty) {
      return "Who would you like to send a message to?";
    }

    return "I'd love to send a message to $contact${message.isNotEmpty ? ' saying: $message' : ''}. Messaging features are coming soon! For now, please open your messaging app manually.";
  }

  String _handleReminder(Intent intent) {
    String reminderText = intent.parameters['reminderText'] ?? '';
    String time = intent.parameters['time'] ?? '';

    if (reminderText.isEmpty) {
      return "What would you like me to remind you about?";
    }

    // For now, just acknowledge the reminder
    String response = "I'd love to set a reminder for '$reminderText'";
    if (time.isNotEmpty) {
      response += " at $time";
    }
    response += ". Reminder functionality is coming soon!";

    return response;
  }

  String _handleCalendar(Intent intent) {
    return "I can help with calendar events soon! For now, please use your calendar app directly.";
  }

  String _handleCalculation(Intent intent) {
    String expression = intent.parameters['expression'] ?? '';

    if (expression.isEmpty) {
      return "What would you like me to calculate?";
    }

    try {
      double result = _calculator.evaluate(expression);
      return "The answer is ${result.toString()}.";
    } catch (e) {
      return "I couldn't calculate that. Please check your expression and try again.";
    }
  }

  String _handleQuestion(Intent intent) {
    String question = intent.originalText;
    
    // Basic question handling
    if (question.toLowerCase().contains('what time')) {
      return _handleTimeQuery(intent);
    }
    
    return "That's an interesting question! I'm still learning how to answer complex questions. For now, I can help with apps, searches, time, and basic calculations.";
  }

  String _handleUnknown(Intent intent) {
    List<String> responses = [
      "I'm not sure I understood that. Could you try rephrasing?",
      "I didn't quite catch that. I can help with opening apps, searching the web, and system controls.",
      "Could you say that differently? I'm great at opening apps, web searches, and system controls.",
      "I'm still learning! Try asking me to open an app, search for something, or tell you the time.",
    ];
    
    return responses[DateTime.now().millisecond % responses.length];
  }
}