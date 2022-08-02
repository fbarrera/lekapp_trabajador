import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email') ?? '';
  runApp(
    MaterialApp(
        home: email == '' ? LoginScreen() : MainScreen(),
        routes: {
          '/login': (BuildContext context) => LoginScreen(),
          '/main': (BuildContext context) => MainScreen(),
        },
        debugShowCheckedModeBanner: false),
  );
}



//main