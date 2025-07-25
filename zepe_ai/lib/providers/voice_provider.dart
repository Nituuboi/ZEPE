import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceState {
  idle,
  listening,
  speaking,
  processing,
}

class VoiceProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  VoiceState _currentState = VoiceState.idle;
  String _lastSpokenText = '';
  String _recognizedText = '';
  bool _isInitialized = false;
  double _confidence = 0.0;
  Function(String)? _onVoiceInputCallback;
  
  // Getters
  VoiceState get currentState => _currentState;
  String get lastSpokenText => _lastSpokenText;
  String get recognizedText => _recognizedText;
  bool get isInitialized => _isInitialized;
  double get confidence => _confidence;
  bool get isListening => _speechToText.isListening;
  bool get isSpeaking => _currentState == VoiceState.speaking;
  
  VoiceProvider() {
    _initializeVoiceServices();
  }
  
  void setVoiceInputCallback(Function(String) callback) {
    _onVoiceInputCallback = callback;
  }
  
  Future<void> _initializeVoiceServices() async {
    try {
      // Initialize TTS
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Set TTS callbacks
      _flutterTts.setStartHandler(() {
        _updateState(VoiceState.speaking);
      });
      
      _flutterTts.setCompletionHandler(() {
        _updateState(VoiceState.idle);
      });
      
      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _updateState(VoiceState.idle);
      });
      
      // Initialize Speech Recognition
      bool speechAvailable = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          _updateState(VoiceState.idle);
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _updateState(VoiceState.idle);
          }
        },
      );
      
      _isInitialized = speechAvailable;
      debugPrint('Voice services initialized: $speechAvailable');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing voice services: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }
  
  void _updateState(VoiceState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      notifyListeners();
    }
  }
  
  Future<bool> startListening() async {
    if (!_isInitialized) {
      await _initializeVoiceServices();
      if (!_isInitialized) return false;
    }
    
    // Check microphone permission
    final permission = await Permission.microphone.status;
    if (!permission.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) return false;
    }
    
    if (_speechToText.isListening) {
      stopListening();
      return false;
    }
    
    try {
      _updateState(VoiceState.listening);
      _recognizedText = '';
      _confidence = 0.0;
      
      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
          notifyListeners();
          
          if (result.finalResult) {
            _handleVoiceInput(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _updateState(VoiceState.idle);
      return false;
    }
  }
  
  void stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _updateState(VoiceState.idle);
  }
  
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      _lastSpokenText = text;
      _updateState(VoiceState.speaking);
      
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error in text-to-speech: $e');
      _updateState(VoiceState.idle);
    }
  }
  
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _updateState(VoiceState.idle);
  }
  
  void _handleVoiceInput(String input) {
    if (input.trim().isEmpty) return;
    
    _updateState(VoiceState.processing);
    
    // Use the callback to let the brain provider handle the input
    if (_onVoiceInputCallback != null) {
      _onVoiceInputCallback!(input);
    } else {
      // Fallback to basic echo functionality
      String response = _generateBasicResponse(input);
      Future.delayed(const Duration(milliseconds: 500), () {
        speak(response);
      });
    }
  }
  
  String _generateBasicResponse(String input) {
    String lowerInput = input.toLowerCase().trim();
    
    // Basic greetings
    if (lowerInput.contains('hello') || lowerInput.contains('hi')) {
      return "Hello! I'm ZEPE, your superhuman voice assistant. How can I help you?";
    }
    
    if (lowerInput.contains('how are you')) {
      return "I'm doing great! I'm here and ready to assist you with anything you need.";
    }
    
    if (lowerInput.contains('what is your name') || lowerInput.contains('who are you')) {
      return "I'm ZEPE AI, a 10,000x smarter voice intelligence that can control your phone and help with any task.";
    }
    
    if (lowerInput.contains('thank you') || lowerInput.contains('thanks')) {
      return "You're welcome! I'm always here to help.";
    }
    
    if (lowerInput.contains('goodbye') || lowerInput.contains('bye')) {
      return "Goodbye! Feel free to wake me up anytime you need assistance.";
    }
    
    // Default response with echo
    return "I heard you say: $input. I'm still learning, but I'll help you with that soon!";
  }
  
  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}