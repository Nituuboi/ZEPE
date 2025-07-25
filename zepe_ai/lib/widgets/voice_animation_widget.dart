import 'package:flutter/material.dart';

class VoiceAnimationWidget extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double size;

  const VoiceAnimationWidget({
    super.key,
    this.isActive = false,
    this.color = const Color(0xFF6C63FF),
    this.size = 100.0,
  });

  @override
  State<VoiceAnimationWidget> createState() => _VoiceAnimationWidgetState();
}

class _VoiceAnimationWidgetState extends State<VoiceAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.3),
        ),
        child: Icon(
          Icons.mic_none,
          color: widget.color,
          size: widget.size * 0.4,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: widget.size * (0.8 + _animation.value * 0.2),
                height: widget.size * (0.8 + _animation.value * 0.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.3 * (1 - _animation.value)),
                    width: 2,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: widget.size * (0.6 + _animation.value * 0.15),
                height: widget.size * (0.6 + _animation.value * 0.15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withOpacity(0.5 * (1 - _animation.value)),
                    width: 2,
                  ),
                ),
              ),
              // Inner circle
              Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: widget.size * 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}