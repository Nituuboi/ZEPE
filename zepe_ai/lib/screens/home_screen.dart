import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../providers/zepe_brain_provider.dart';
import '../widgets/conversation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // Set up voice input callback after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
      final brainProvider = Provider.of<ZepeBrainProvider>(context, listen: false);
      
      voiceProvider.setVoiceInputCallback((input) async {
        String response = await brainProvider.processInput(input);
        if (response.isNotEmpty) {
          voiceProvider.speak(response);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onVoiceButtonPressed() {
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    
    if (voiceProvider.isListening) {
      voiceProvider.stopListening();
    } else {
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      
      voiceProvider.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Voice Interface
              Expanded(
                flex: 3,
                child: _buildVoiceInterface(),
              ),
              
              // Conversation History
              Expanded(
                flex: 2,
                child: const ConversationWidget(),
              ),
              
              // Bottom Controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZEPE AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Superhuman Voice Intelligence',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Consumer<VoiceProvider>(
            builder: (context, voiceProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: voiceProvider.isInitialized 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: voiceProvider.isInitialized 
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  voiceProvider.isInitialized ? 'READY' : 'OFFLINE',
                  style: TextStyle(
                    color: voiceProvider.isInitialized 
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInterface() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Text
            Text(
              _getStatusText(voiceProvider.currentState),
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Voice Button with Animation
            GestureDetector(
              onTap: _onVoiceButtonPressed,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple Effect
                  if (voiceProvider.isListening)
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200 + (_rippleAnimation.value * 100),
                          height: 200 + (_rippleAnimation.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(
                                0.5 - (_rippleAnimation.value * 0.5),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Main Voice Button
                  AnimatedBuilder(
                    animation: voiceProvider.isListening 
                        ? _pulseAnimation 
                        : const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: voiceProvider.isListening 
                            ? _pulseAnimation.value 
                            : 1.0,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: voiceProvider.isListening
                                  ? [
                                      const Color(0xFF6C63FF),
                                      const Color(0xFF8B7CF6),
                                    ]
                                  : voiceProvider.isSpeaking
                                      ? [
                                          const Color(0xFF10B981),
                                          const Color(0xFF34D399),
                                        ]
                                      : [
                                          const Color(0xFF6B7280),
                                          const Color(0xFF9CA3AF),
                                        ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (voiceProvider.isListening 
                                    ? const Color(0xFF6C63FF)
                                    : voiceProvider.isSpeaking
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF6B7280)
                                ).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            voiceProvider.isListening
                                ? Icons.mic
                                : voiceProvider.isSpeaking
                                    ? Icons.volume_up
                                    : Icons.mic_none,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Recognized Text
            if (voiceProvider.recognizedText.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'I heard:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voiceProvider.recognizedText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (voiceProvider.confidence > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Confidence: ${(voiceProvider.confidence * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              // TODO: Open settings
            },
          ),
          _buildControlButton(
            icon: Icons.history,
            label: 'History',
            onTap: () {
              final brainProvider = Provider.of<ZepeBrainProvider>(context, listen: false);
              brainProvider.clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conversation history cleared'),
                  backgroundColor: const Color(0xFF6C63FF),
                ),
              );
            },
          ),
          _buildControlButton(
            icon: Icons.help_outline,
            label: 'Help',
            onTap: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(VoiceState state) {
    switch (state) {
      case VoiceState.idle:
        return 'Tap to speak with ZEPE';
      case VoiceState.listening:
        return 'Listening... Speak now';
      case VoiceState.speaking:
        return 'ZEPE is speaking...';
      case VoiceState.processing:
        return 'Processing your request...';
      default:
        return 'Ready to help';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'How to use ZEPE AI',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('• "Open YouTube" - Launch apps'),
            _buildHelpItem('• "Search for cats" - Web search'),
            _buildHelpItem('• "What time is it?" - Get current time'),
            _buildHelpItem('• "Turn on WiFi" - System controls'),
            _buildHelpItem('• "Calculate 25 + 17" - Math calculations'),
            const SizedBox(height: 16),
            Text(
              'Just tap the microphone and speak naturally!',
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it!',
              style: TextStyle(color: const Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}