import 'package:flutter/material.dart';

// This is the main StatefulWidget that will hold the animation logic
class ThreeDots extends StatefulWidget {
  const ThreeDots({super.key});

  @override
  // The warning "Invalid use of a private type in a public API" might appear in the IDE 
  // if you were trying to expose _ThreeDotsState externally, but here 
  // it's correctly used as the internal state.
  _ThreeDotsState createState() => _ThreeDotsState();
}

// The State class with SingleTickerProviderStateMixin for the AnimationController
class _ThreeDotsState extends State<ThreeDots> with SingleTickerProviderStateMixin {
  // Late initialization is used for a non-nullable variable that will be initialized 
  // in initState, which is called before the first build.
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // The duration is set to 500ms * 3, which is 1500ms (1.5 seconds) for a full cycle.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500) * 3,
      vsync: this,
    )..repeat(); // The repeat() method makes the animation loop indefinitely.
  }

  @override
  void dispose() {
    // It's crucial to dispose of the controller to free up resources.
    _controller.dispose();
    super.dispose();
  }

  // Helper method to build a single animated dot
  Widget _buildDot(int index) {
    return ScaleTransition(
      // Scale up and down for a bouncy effect
      scale: CurvedAnimation(
        // This calculates an interval for each dot. 
        // e.g., Dot 0 animates from 0.0 to 0.33, Dot 1 from 0.33 to 0.66, etc.
        parent: _controller,
        curve: Interval(
          (index / 3), // Start point of the animation segment
          (index + 1) / 3, // End point of the animation segment
          curve: Curves.easeInOut, // Smooth acceleration and deceleration
        ),
      ),
      child: Container(
        // The dot's appearance
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: Colors.green, // You can change this color
          shape: BoxShape.circle,
        ),
      ),
    ); // ScaleTransition
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // Center the dots horizontally within the available space
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3, // Generates a list of 3 items (for the three dots)
        _buildDot, // Uses the _buildDot function to create each item
      ).map((dot) => Padding(
        // Add horizontal padding between the dots
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: dot,
      )).toList(), // Convert the iterable back to a list of Widgets for the Row
    ); // Row
  }
}