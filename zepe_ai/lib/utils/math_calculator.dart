import 'dart:math' as math;

class MathCalculator {
  double evaluate(String expression) {
    // Simple expression evaluator
    String cleanExpression = expression.replaceAll(' ', '');
    
    // Handle basic arithmetic operations
    if (cleanExpression.contains('+')) {
      List<String> parts = cleanExpression.split('+');
      if (parts.length == 2) {
        return _parseNumber(parts[0]) + _parseNumber(parts[1]);
      }
    }
    
    if (cleanExpression.contains('-')) {
      List<String> parts = cleanExpression.split('-');
      if (parts.length == 2) {
        return _parseNumber(parts[0]) - _parseNumber(parts[1]);
      }
    }
    
    if (cleanExpression.contains('*')) {
      List<String> parts = cleanExpression.split('*');
      if (parts.length == 2) {
        return _parseNumber(parts[0]) * _parseNumber(parts[1]);
      }
    }
    
    if (cleanExpression.contains('/')) {
      List<String> parts = cleanExpression.split('/');
      if (parts.length == 2) {
        double divisor = _parseNumber(parts[1]);
        if (divisor == 0) throw Exception('Division by zero');
        return _parseNumber(parts[0]) / divisor;
      }
    }
    
    // Handle single number or more complex expressions
    return _parseNumber(cleanExpression);
  }
  
  double _parseNumber(String numberStr) {
    // Remove any non-numeric characters except decimal point and negative sign
    String cleaned = numberStr.replaceAll(RegExp(r'[^0-9.-]'), '');
    
    try {
      return double.parse(cleaned);
    } catch (e) {
      throw Exception('Invalid number format: $numberStr');
    }
  }
  
  // Additional math functions
  double sqrt(double number) => math.sqrt(number);
  double pow(double base, double exponent) => math.pow(base, exponent).toDouble();
  double sin(double radians) => math.sin(radians);
  double cos(double radians) => math.cos(radians);
  double tan(double radians) => math.tan(radians);
}