// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_manager/authetication/authentication_with_google.dart';
import 'package:password_manager/colors.dart';

import 'package:password_manager/profile_screen.dart';
import 'package:password_manager/screens/password_genrator.dart';
import 'package:password_manager/security_section/signIn_screen.dart';
import 'package:provider/provider.dart';

import 'search_credentials.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final storage = FlutterSecureStorage();

  delay() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  String SignInWith = 'NULL';

  isGoogleLogin() async {
    String? value = await storage.read(key: 'signInWith') ?? 'NULL';
    setState(() {
      SignInWith = value;
    });
    print('isGoogleLogin value is reading: $SignInWith');
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await storage.delete(key: 'uid');
  }

  googleSignOut() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    provider.logOut();
    await storage.delete(key: 'uid');
  }

  @override
  void initState() {
    super.initState();
    isGoogleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            splashColor: whiteColor,
            splashRadius: 10.0,
            icon: Icon(Icons.account_circle, color: whiteColor, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          title: const Text('Password Manager'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: whiteColor),
              onPressed: () async {
                SignInWith == 'GOOGLE' ? googleSignOut() : signOut();
                print('SignOut called');
                await Fluttertoast.showToast(
                  msg: 'User Logout Successfully', // message
                  toastLength: Toast.LENGTH_SHORT, // length
                  gravity: ToastGravity.BOTTOM, // location
                  backgroundColor: Colors.green,
                );
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                    (route) => false);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(60.0, 60.0),
            child: TabBar(
              indicatorColor: whiteColor,
              labelColor: whiteColor,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 5.0, color: whiteColor),
                  insets: const EdgeInsets.symmetric(horizontal: 20.0)),
              tabs: const [
                Tab(text: 'Password Generator'),
                Tab(text: 'Saved Credentials'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PasswordGenerator(),
            SearchCredentials(),
          ],
        ),
      ),
    );
  }
}
