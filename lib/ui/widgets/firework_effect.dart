import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class FireworksEffect extends StatelessWidget {
  final ConfettiController leftController;
  final ConfettiController rightController;

  const FireworksEffect({
    super.key,
    required this.leftController,
    required this.rightController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: leftController,
            blastDirection: 0, // Bắn sang phải
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            blastDirectionality: BlastDirectionality.directional,
            maxBlastForce: 20,
            minBlastForce: 5,
            gravity: 0.3,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: rightController,
            blastDirection: 3.14, // Bắn sang trái (pi radian)
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            blastDirectionality: BlastDirectionality.directional,
            maxBlastForce: 20,
            minBlastForce: 5,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
