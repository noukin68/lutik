import 'package:flutter/material.dart';
import 'package:web_parental_control/widgets/login_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const NewLoginPage(),
    );
  }
}
