import 'package:flutter/material.dart';

class CustomDrawerButton extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onPressed;

  const CustomDrawerButton({
    required this.animationController,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top line
                  Transform.translate(
                    offset: Offset(0, -6 + 6 * animationController.value),
                    child: Transform.rotate(
                      angle: animationController.value * 0.8, // ~45 degrees
                      child: Container(
                        height: 2.5,
                        width: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Middle line
                  Opacity(
                    opacity: 1 - animationController.value,
                    child: Container(
                      height: 2.5,
                      width: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Bottom line
                  Transform.translate(
                    offset: Offset(0, 6 - 6 * animationController.value),
                    child: Transform.rotate(
                      angle: -animationController.value * 0.8, // ~-45 degrees
                      child: Container(
                        height: 2.5,
                        width: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}