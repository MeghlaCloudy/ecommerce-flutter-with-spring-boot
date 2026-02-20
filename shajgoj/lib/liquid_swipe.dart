// import 'package:flutter/material.dart';
// import 'package:liquid_swipe/liquid_swipe.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LiquidSwipePage(),
//     );
//   }
// }

// class LiquidSwipePage extends StatelessWidget {
//   final pages = [
//     Container(color: Colors.red),
//     Container(color: Colors.blue),
//     Container(color: Colors.green),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LiquidSwipe(
//         pages: pages,
//         fullTransitionValue: 600,
//         enableLoop: true,
//         waveType: WaveType.liquidReveal,
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiquidSwipePage(),
    );
  }
}

class LiquidSwipePage extends StatelessWidget {
  // Pages for LiquidSwipe
  final pages = [
    // First page with image and text
    _buildPage(
      'assets/images/banner-1.jpg',
      'Welcome to MyApp!',
      'Swipe to start',
    ),

    // Second page with image and text
    _buildPage(
      'assets/images/banner2.jpg',
      'Explore Features',
      'Swipe for more',
    ),

    // Third page with image and text
    _buildPage('assets/images/banner3.jpg', 'Enjoy the App!', 'Let\'s go!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidSwipe(
        pages: pages,
        fullTransitionValue: 600,
        enableLoop: true,
        waveType: WaveType.liquidReveal,
      ),
    );
  }

  // Method to create each page with image and text
  static Widget _buildPage(String imagePath, String title, String subtitle) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 30),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 10),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

