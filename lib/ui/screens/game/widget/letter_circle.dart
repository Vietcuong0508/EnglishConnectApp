import 'dart:math';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';

extension LetterCircleWidget on GameScreenState {
  Widget letterCircleWidget(
    String letter,
    int index,
    int totalLetters,
    Offset center,
    double radius,
    double baseSize,
    double baseLetterSize, {
    required bool selected,
    required Animation<double> celebrationAnimation,
    required Animation<double> shakeAnimation,
    required GlobalKey keyWidget,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final startAngle = -pi / 2;
    final angleStep = 2 * pi / totalLetters;
    final angle = startAngle + angleStep * index;

    final dx = center.dx + radius * cos(angle);
    final dy = center.dy + radius * sin(angle);

    final double circleSize = totalLetters > 8 ? baseSize * 0.6 : baseSize;
    final double letterSize =
        totalLetters > 8 ? baseLetterSize * 0.6 : baseLetterSize;

    return AnimatedBuilder(
      animation: celebrationAnimation,
      builder: (context, child) {
        final scale = selected ? 1.0 + celebrationAnimation.value * 0.3 : 1.0;

        return AnimatedBuilder(
          animation: shakeAnimation,
          builder: (context, child) {
            final shakeOffset =
                selected
                    ? Offset(
                      shakeAnimation.value * sin(shakeAnimation.value * 2 * pi),
                      0,
                    )
                    : Offset.zero;

            return Positioned(
              left: dx - circleSize / 2 + shakeOffset.dx,
              top: dy - circleSize / 2 + shakeOffset.dy,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  key: keyWidget,
                  width: circleSize,
                  height: circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? backgroundColor
                            : backgroundColor.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: selected ? 3 : 1,
                        blurRadius: selected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    letter.toUpperCase(),
                    style: TextStyle(
                      fontSize: letterSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
