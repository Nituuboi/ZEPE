import 'package:flutter/foundation.dart';
import '../models/intent_model.dart';

class IntentService {
  static final IntentService _instance = IntentService._internal();
  factory IntentService() => _instance;
  IntentService._internal();

  final Map<IntentType, List<String>> _intentPatterns = {
    IntentType.greeting: [
      'hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening',
      'greetings', 'what\'s up', 'howdy'
    ],
    IntentType.farewell: [
      'goodbye', 'bye', 'see you', 'farewell', 'talk to you later',
      'until next time', 'catch you later'
    ],
    IntentType.appLaunch: [
      'open', 'launch', 'start', 'run', 'execute', 'load'
    ],
    IntentType.webSearch: [
      'search', 'google', 'look up', 'find', 'search for', 'google search'
    ],
    IntentType.timeQuery: [
      'time', 'what time', 'current time', 'clock', 'what\'s the time'
    ],
    IntentType.weatherQuery: [
      'weather', 'temperature', 'forecast', 'how\'s the weather',
      'what\'s the weather like'
    ],
    IntentType.systemControl: [
      'volume', 'brightness', 'wifi', 'bluetooth', 'airplane mode',
      'turn on', 'turn off', 'enable', 'disable'
    ],
    IntentType.phoneCall: [
      'call', 'phone', 'dial', 'ring', 'contact'
    ],
    IntentType.textMessage: [
      'text', 'message', 'sms', 'send message', 'send text'
    ],
    IntentType.reminder: [
      'remind', 'reminder', 'set reminder', 'don\'t forget'
    ],
    IntentType.calendar: [
      'calendar', 'schedule', 'appointment', 'meeting', 'event'
    ],
    IntentType.calculation: [
      'calculate', 'math', 'plus', 'minus', 'multiply', 'divide',
      'what is', 'compute'
    ],
    IntentType.question: [
      'what', 'how', 'when', 'where', 'why', 'who', 'which'
    ],
  };

  Future<Intent> parseIntent(String userInput) async {
    String normalizedInput = userInput.toLowerCase().trim();
    
    // Check for each intent type
    for (var entry in _intentPatterns.entries) {
      IntentType intentType = entry.key;
      List<String> patterns = entry.value;
      
      for (String pattern in patterns) {
        if (normalizedInput.contains(pattern)) {
          Map<String, dynamic> parameters = _extractParameters(intentType, userInput);
          double confidence = _calculateConfidence(pattern, normalizedInput);
          
          debugPrint('Detected intent: $intentType with confidence: $confidence');
          
          return Intent(
            type: intentType,
            originalText: userInput,
            parameters: parameters,
            confidence: confidence,
          );
        }
      }
    }

    // Default to unknown intent
    return Intent(
      type: IntentType.unknown,
      originalText: userInput,
      confidence: 0.0,
    );
  }

  Map<String, dynamic> _extractParameters(IntentType intentType, String input) {
    Map<String, dynamic> parameters = {};

    switch (intentType) {
      case IntentType.appLaunch:
        parameters['appName'] = _extractAppName(input);
        break;
        
      case IntentType.webSearch:
        parameters['query'] = _extractSearchQuery(input);
        break;
        
      case IntentType.phoneCall:
        parameters['contact'] = _extractContactName(input);
        parameters['phoneNumber'] = _extractPhoneNumber(input);
        break;
        
      case IntentType.textMessage:
        parameters['contact'] = _extractContactName(input);
        parameters['message'] = _extractMessageContent(input);
        break;
        
      case IntentType.reminder:
        parameters['reminderText'] = _extractReminderText(input);
        parameters['time'] = _extractTime(input);
        break;
        
      case IntentType.systemControl:
        parameters['action'] = _extractSystemAction(input);
        parameters['target'] = _extractSystemTarget(input);
        break;
        
      case IntentType.calculation:
        parameters['expression'] = _extractMathExpression(input);
        break;
        
      default:
        break;
    }

    return parameters;
  }

  String _extractAppName(String input) {
    // Remove common app launch phrases and extract app name
    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'\b(open|launch|start|run|execute|load)\b'), '')
        .trim();
    
    // Common app name mappings
    Map<String, String> appMappings = {
      'youtube': 'YouTube',
      'chrome': 'Chrome',
      'gmail': 'Gmail',
      'whatsapp': 'WhatsApp',
      'instagram': 'Instagram',
      'facebook': 'Facebook',
      'twitter': 'Twitter',
      'spotify': 'Spotify',
      'netflix': 'Netflix',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'photos': 'Photos',
      'maps': 'Maps',
      'settings': 'Settings',
      'calculator': 'Calculator',
      'calendar': 'Calendar',
      'clock': 'Clock',
      'contacts': 'Contacts',
      'phone': 'Phone',
      'messages': 'Messages',
    };
    
    for (var entry in appMappings.entries) {
      if (cleaned.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return cleaned;
  }

  String _extractSearchQuery(String input) {
    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'\b(search|google|look up|find|search for|google search)\b'), '')
        .replaceAll(RegExp(r'\bfor\b'), '')
        .trim();
    return cleaned;
  }

  String _extractContactName(String input) {
    // Extract contact name after call/text keywords
    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'\b(call|phone|dial|ring|contact|text|message|sms|send message|send text)\b'), '')
        .trim();
    return cleaned;
  }

  String _extractPhoneNumber(String input) {
    // Extract phone number pattern
    RegExp phoneRegex = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    Match? match = phoneRegex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  String _extractMessageContent(String input) {
    // Extract message content after "saying" or similar keywords
    List<String> messagePrefixes = ['saying', 'that says', 'message', 'text'];
    for (String prefix in messagePrefixes) {
      int index = input.toLowerCase().indexOf(prefix);
      if (index != -1) {
        return input.substring(index + prefix.length).trim();
      }
    }
    return '';
  }

  String _extractReminderText(String input) {
    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'\b(remind|reminder|set reminder|don[\'']t forget)\b'), '')
        .replaceAll(RegExp(r'\bme\b'), '')
        .replaceAll(RegExp(r'\bto\b'), '')
        .trim();
    return cleaned;
  }

  String _extractTime(String input) {
    // Extract time patterns
    RegExp timeRegex = RegExp(r'\b\d{1,2}:\d{2}\s?(am|pm)?\b', caseSensitive: false);
    Match? match = timeRegex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  String _extractSystemAction(String input) {
    if (input.toLowerCase().contains('turn on') || input.toLowerCase().contains('enable')) {
      return 'enable';
    } else if (input.toLowerCase().contains('turn off') || input.toLowerCase().contains('disable')) {
      return 'disable';
    } else if (input.toLowerCase().contains('increase') || input.toLowerCase().contains('up')) {
      return 'increase';
    } else if (input.toLowerCase().contains('decrease') || input.toLowerCase().contains('down')) {
      return 'decrease';
    }
    return 'toggle';
  }

  String _extractSystemTarget(String input) {
    String lowerInput = input.toLowerCase();
    if (lowerInput.contains('wifi')) return 'wifi';
    if (lowerInput.contains('bluetooth')) return 'bluetooth';
    if (lowerInput.contains('airplane')) return 'airplane_mode';
    if (lowerInput.contains('volume')) return 'volume';
    if (lowerInput.contains('brightness')) return 'brightness';
    return '';
  }

  String _extractMathExpression(String input) {
    // Extract mathematical expressions
    String cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'\b(calculate|math|what is|compute)\b'), '')
        .replaceAll('plus', '+')
        .replaceAll('minus', '-')
        .replaceAll('times', '*')
        .replaceAll('multiply', '*')
        .replaceAll('divided by', '/')
        .replaceAll('divide', '/')
        .trim();
    return cleaned;
  }

  double _calculateConfidence(String pattern, String input) {
    // Simple confidence calculation based on pattern match
    double baseConfidence = 0.7;
    
    // Exact match gets higher confidence
    if (input == pattern) return 1.0;
    
    // Longer patterns get higher confidence
    if (pattern.length > 5) baseConfidence += 0.1;
    
    // Patterns at the beginning of input get higher confidence
    if (input.startsWith(pattern)) baseConfidence += 0.1;
    
    return baseConfidence.clamp(0.0, 1.0);
  }
}