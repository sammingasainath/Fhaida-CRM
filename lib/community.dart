import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FullScreenImagePage(),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(
              context); // Optional: Close the full screen image when tapped.
        },
        child: Container(
          // Fills the whole screen with the image, ignoring safe areas.

          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/image1.png'), // Replace with your asset path
              fit: BoxFit.cover, // Covers the whole screen
            ),
          ),
        ),
      ),
    );
  }
}
