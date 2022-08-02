import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Color whiteColor = Colors.white;
Color blackColor = Colors.black;
Color tealColor = Colors.teal;

final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
