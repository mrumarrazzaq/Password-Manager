// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_manager/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final storage = FlutterSecureStorage();
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  String SignInWith = 'NULL';
  getFirestoreData() async {
    final user = FirebaseAuth.instance.currentUser;
    print(user!.email);
    print('-------------------------------------');
    print('Current user data is fetching');
    try {
      await FirebaseFirestore.instance
          .collection('User Data')
          .doc(user.email)
          .get()
          .then((ds) {
        userName = ds['User Name'];
        userEmail = ds['User Email'];
        userPassword = ds['User Password'];
      });
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  isGoogleLogin() async {
    String? value = await storage.read(key: 'signInWith') ?? 'NULL';
    setState(() {
      SignInWith = value;
    });
    print('isGoogleLogin value is reading: $SignInWith');
  }

  copyData({required String title, required String message}) {
    setState(() {
      final data = ClipboardData(text: title);
      Clipboard.setData(data);
    });
    Fluttertoast.showToast(
      msg: message, // message
      toastLength: Toast.LENGTH_SHORT, // length
      gravity: ToastGravity.BOTTOM, // location
      backgroundColor: Colors.grey,
      timeInSecForIosWeb: 1,
    );
  }

  @override
  void initState() {
    super.initState();
    getFirestoreData();
    isGoogleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
          child: SignInWith == 'GOOGLE'
              ? Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(user.photoURL!),
                      backgroundColor: tealColor,
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Name'),
                        subtitle: Text(
                          '${user.displayName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            copyData(
                              title: userPassword,
                              message: 'Name Copied',
                            );
                          },
                          splashRadius: 25.0,
                          icon: const Icon(
                            Icons.copy,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Email'),
                        subtitle: Text(
                          '${user.email}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            copyData(
                              title: userPassword,
                              message: 'Email Copied',
                            );
                          },
                          splashRadius: 25.0,
                          icon: const Icon(
                            Icons.copy,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Name'),
                        subtitle: Text(userName),
                        trailing: IconButton(
                          onPressed: () {
                            copyData(
                              title: userName,
                              message: 'Name Copied',
                            );
                          },
                          splashRadius: 25.0,
                          icon: const Icon(
                            Icons.copy,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Email'),
                        subtitle: Text(userEmail),
                        trailing: IconButton(
                          onPressed: () {
                            copyData(
                              title: userEmail,
                              message: 'Email Copied',
                            );
                          },
                          splashRadius: 25.0,
                          icon: const Icon(
                            Icons.copy,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Password'),
                        subtitle: const Text(
                          '.............',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            copyData(
                              title: userPassword,
                              message: 'Password Copied',
                            );
                          },
                          splashRadius: 25.0,
                          icon: const Icon(
                            Icons.copy,
                            size: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
