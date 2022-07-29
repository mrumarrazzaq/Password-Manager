// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/security_section/signIn_screen.dart';
import 'screens/my_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();

  bool isLogin = false;

  checkLoginStatus() async {
    String? value = await storage.read(key: 'uid');
    if (value == null) {
      print('---------------');
      print('User is logOUT');
      isLogin = false;
      // return false;
    } else {
      print('---------------');
      print('User is logIN');
      isLogin = true;
      // return true;
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: isLogin ? const MyHomeScreen() : const SignInScreen(),
      // const MyHomeScreen(),
    );
  }
}
