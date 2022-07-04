import 'package:flutter/material.dart';
import 'package:simple_animations/multi_tween/multi_tween.dart';
import 'package:simple_animations/stateless_animation/play_animation.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween();
    Tween(begin: 0.0, end: 1.0);
    Tween(begin: -30.0, end: 0.0); Duration(milliseconds: 500); Curves.easeOut;

    return PlayAnimation<MultiTweenValues>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, animation) => Opacity(
        opacity:1,
        child: Transform.translate(
            offset: Offset(0, 1),
            child: child
        ),
      ),
    );
  }
}