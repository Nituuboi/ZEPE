enum IntentType {
  greeting,
  farewell,
  question,
  command,
  appLaunch,
  webSearch,
  timeQuery,
  weatherQuery,
  systemControl,
  phoneCall,
  textMessage,
  reminder,
  calendar,
  calculation,
  unknown,
}

class Intent {
  final IntentType type;
  final String originalText;
  final Map<String, dynamic> parameters;
  final double confidence;
  final DateTime timestamp;

  Intent({
    required this.type,
    required this.originalText,
    this.parameters = const {},
    this.confidence = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'Intent(type: $type, text: "$originalText", confidence: $confidence, params: $parameters)';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'originalText': originalText,
      'parameters': parameters,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Intent.fromJson(Map<String, dynamic> json) {
    return Intent(
      type: IntentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => IntentType.unknown,
      ),
      originalText: json['originalText'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}