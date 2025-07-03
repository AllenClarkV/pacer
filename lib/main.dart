import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacer/pages/striva.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xff141413),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: "Poppins",
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const Striva(),
    );
  }
}
