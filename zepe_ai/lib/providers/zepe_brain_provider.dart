import 'package:flutter/foundation.dart';
import '../services/intent_service.dart';
import '../services/action_executor.dart';
import '../models/intent_model.dart';

class ZepeBrainProvider extends ChangeNotifier {
  final IntentService _intentService = IntentService();
  final ActionExecutor _actionExecutor = ActionExecutor();
  
  List<String> _conversationHistory = [];
  Map<String, dynamic> _context = {};
  bool _isProcessing = false;
  
  // Getters
  List<String> get conversationHistory => List.unmodifiable(_conversationHistory);
  Map<String, dynamic> get context => Map.unmodifiable(_context);
  bool get isProcessing => _isProcessing;
  
  ZepeBrainProvider() {
    _initializeBrain();
  }
  
  void _initializeBrain() {
    _context = {
      'userName': 'User',
      'lastInteraction': DateTime.now(),
      'preferences': {},
      'deviceInfo': {},
    };
    debugPrint('ZEPE Brain initialized');
  }
  
  Future<String> processInput(String userInput) async {
    if (userInput.trim().isEmpty) return '';
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Add to conversation history
      _conversationHistory.add('User: $userInput');
      
      // Parse intent
      Intent intent = await _intentService.parseIntent(userInput);
      
      // Execute action based on intent
      String response = await _actionExecutor.executeAction(intent);
      
      // Add response to history
      _conversationHistory.add('ZEPE: $response');
      
      // Update context
      _updateContext(intent, response);
      
      _isProcessing = false;
      notifyListeners();
      
      return response;
    } catch (e) {
      debugPrint('Error processing input: $e');
      _isProcessing = false;
      notifyListeners();
      return "I'm having trouble processing that right now. Please try again.";
    }
  }
  
  void _updateContext(Intent intent, String response) {
    _context['lastInteraction'] = DateTime.now();
    _context['lastIntent'] = intent.type.toString();
    
    // Store relevant context based on intent type
    switch (intent.type) {
      case IntentType.greeting:
        _context['lastGreeting'] = DateTime.now();
        break;
      case IntentType.appLaunch:
        _context['lastAppLaunched'] = intent.parameters['appName'];
        break;
      case IntentType.webSearch:
        _context['lastSearchQuery'] = intent.parameters['query'];
        break;
      case IntentType.timeQuery:
        _context['lastTimeQuery'] = DateTime.now();
        break;
      default:
        break;
    }
    
    // Keep history manageable
    if (_conversationHistory.length > 20) {
      _conversationHistory = _conversationHistory.sublist(_conversationHistory.length - 20);
    }
  }
  
  void clearHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }
  
  void updateUserPreferences(Map<String, dynamic> preferences) {
    _context['preferences'] = {..._context['preferences'], ...preferences};
    notifyListeners();
  }
  
  String getContextualResponse(String baseResponse) {
    // Add contextual awareness to responses
    final lastInteraction = _context['lastInteraction'] as DateTime?;
    if (lastInteraction != null) {
      final timeSinceLastInteraction = DateTime.now().difference(lastInteraction);
      
      if (timeSinceLastInteraction.inHours > 6) {
        return "Welcome back! $baseResponse";
      } else if (timeSinceLastInteraction.inMinutes > 30) {
        return "Good to hear from you again. $baseResponse";
      }
    }
    
    return baseResponse;
  }
}