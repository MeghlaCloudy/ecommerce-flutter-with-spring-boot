import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_strings.dart';

import 'core/theme/app_theme.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyBeautyApp());
}

class MyBeautyApp extends StatelessWidget {
  const MyBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),

      // পরে routes যোগ করতে চাইলে
      // routes: {
      //   '/home': (context) => const HomeScreen(),

      // },
    );
  }
}
