// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("GestureDetector CircleAvatar"),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: GestureDetector(
//           onTap: () {
//             // Navigate to second page
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => SecondPage()),
//             );
//           },
//           onLongPress: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text("Long Press Detected!"),
//               ),
//             );
//           },
//           child: CircleAvatar(
//             radius: 70,
//             backgroundImage: AssetImage('assets/profile.jpg'),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SecondPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Second Page"),
//       ),
//       body: Center(
//         child: Text(
//           "Welcome to Second Page!",
//           style: TextStyle(fontSize: 22),
//         ),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  void showMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Image Clicked!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GestureDetector CircleAvatar"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Image Gesture
            GestureDetector(
              onTap: () => showMessage(context),
              onLongPress: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Long Press Detected!")));
              },
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/banner3.jpg'),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 Text Gesture
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Text Clicked!")));
              },
              child: Text(
                "Click Me",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

