// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:password_manager/colors.dart';
import 'package:password_manager/genrate_random_password/genrate_random_password.dart';
import 'package:password_manager/security_section/signIn_screen.dart';

final user = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  static const String id = 'RegisterScreen';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isValidEmail = false;
  bool _isLoading = false;

  var personName = "";
  var email = "";
  var password = "";
  var confirmPassword = "";
  var userId = "";

  final personNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final storage = FlutterSecureStorage();

  String? validatePassword(value) {
    if (value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 8) {
      return 'Should be at least 8 characters';
    } else if (value.length > 25) {
      return 'Should not be more than 25 characters';
    } else {
      return null;
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   passwordController.text =
  //       generateRandomPassword(16, true, true, true, true);
  //   confirmPasswordController.text = passwordController.text;
  // }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    personNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  registerNewUser() async {
    if (password == confirmPassword) {
      try {
        _isLoading = true;

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        print(userCredential);

        final json = {
          'User Name': personName,
          'User Email': emailController.text,
          'User Password': passwordController.text,
        };

        user.collection('User Data').doc(email).set(json);

        Fluttertoast.showToast(
          msg: 'Registered Successfully.. Now Login', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'weak-password') {
          // ignore: deprecated_member_use
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Password Provided is too Weak!!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _isLoading = false;
          });

          // ignore: deprecated_member_use
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Sorry! Account Already Exist !',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // ignore: deprecated_member_use
      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Password and Confirm Password doesn\'t match !',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("RegisterScreen Build Run");

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tealColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isLoading ? false : true,
                        // fillColor: purpleColor,
                        // filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.0),
                        ),
                        hintText: 'Enter Name',
                        // hintStyle: TextStyle(color: purpleColor),
                        label: Text('Name', style: TextStyle(color: tealColor)),
                        prefixIcon: Icon(
                          Icons.person,
                          color: tealColor,
                        ),
                        prefixText: '  ',
                      ),
                      controller: personNameController,
                      validator: (String? val) {
                        if (val!.isEmpty) {
                          return "Please enter name";
                        } else if (double.tryParse(val) != null) {
                          return 'numbers not allowed';
                        }
                        return null;
                      },
                    ),
                  ),

                  //Email Address
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isLoading ? false : true,
                        // fillColor: whiteColor,
                        // filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.0),
                        ),
                        hintText: 'Enter Email Id',
                        // hintStyle: TextStyle(color: purpleColor),
                        label: Text('Email Id',
                            style: TextStyle(color: tealColor)),
                        prefixIcon: Icon(
                          Icons.alternate_email,
                          color: tealColor,
                        ),
                        prefixText: '  ',
                        suffixIcon: isValidEmail
                            ? const Icon(Icons.check,
                                color: Colors.green, size: 20.0)
                            : null,
                      ),
                      controller: emailController,
                      validator: MultiValidator(
                        [
                          RequiredValidator(errorText: 'Please enter a email'),
                          EmailValidator(errorText: 'Not a Valid Email'),
                        ],
                      ),
                    ),
                  ),
                  //Password
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      // onTap: () {
                      //   setState(() {
                      //     passwordController.text = generateRandomPassword(
                      //         16, true, true, true, true);
                      //     confirmPasswordController.text =
                      //         passwordController.text;
                      //   });
                      // },
                      obscureText: _obscurePassword,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isLoading ? false : true,
                        // fillColor: whiteColor,
                        // filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintText: 'Enter Password',
                        // hintStyle: TextStyle(color: purpleColor),
                        label: Text('Password',
                            style: TextStyle(color: tealColor)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.0),
                        ),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: tealColor,
                        ),
                        prefixText: '  ',
                        suffixIcon: GestureDetector(
                          child: _obscurePassword
                              ? Icon(
                                  Icons.visibility,
                                  size: 18.0,
                                  color: tealColor,
                                )
                              : Icon(
                                  Icons.visibility_off,
                                  size: 18.0,
                                  color: tealColor,
                                ),
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      controller: passwordController,
                      validator: validatePassword,
                    ),
                  ),
                  //Confirm Password
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: TextFormField(
                      obscureText: _obscureConfirmPassword,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isLoading ? false : true,
                        // fillColor: whiteColor,
                        // filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintText: 'Enter Confirm Password',
                        // hintStyle: TextStyle(color: purpleColor),
                        label: Text('Confirm Password',
                            style: TextStyle(color: tealColor)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.0),
                        ),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: tealColor,
                        ),
                        prefixText: '  ',
                        suffixIcon: GestureDetector(
                          child: _obscureConfirmPassword
                              ? Icon(
                                  Icons.visibility,
                                  size: 18.0,
                                  color: tealColor,
                                )
                              : Icon(
                                  Icons.visibility_off,
                                  size: 18.0,
                                  color: tealColor,
                                ),
                          onTap: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      controller: confirmPasswordController,
                      validator: validatePassword,
                    ),
                  ),
                  //Register Button
                  Material(
                    color: tealColor,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      minWidth: _isLoading ? 50.0 : 160.0,
                      height: 40.0,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (_isLoading) {
                        } else {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isValidEmail = true;
                              personName = personNameController.text;
                              email = emailController.text;
                              password = passwordController.text;
                              confirmPassword = confirmPasswordController.text;
                            });
                            registerNewUser();
                          }
                        }
                      },
                      child: _isLoading
                          ? SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                color: whiteColor,
                                strokeWidth: 3.0,
                              ),
                            )
                          // Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           SizedBox(
                          //             height: 30.0,
                          //             width: 30.0,
                          //             child: CircularProgressIndicator(
                          //               color: whiteColor,
                          //               strokeWidth: 2.0,
                          //             ),
                          //           ),
                          //           const SizedBox(
                          //             width: 15.0,
                          //           ),
                          //           Text(
                          //             'Please Wait',
                          //             style: TextStyle(
                          //               color: whiteColor,
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          : Text(
                              'Register',
                              style: TextStyle(
                                color: whiteColor,
                              ),
                            ),
                    ),
                  ),
                  // TextButton(
                  //     onPressed: () async {
                  //       fcmToken = await _fcm.getToken();
                  //       print('----------------------');
                  //       print('FCM Token : $fcmToken');
                  //       print('----------------------');
                  //     },
                  //     child: Text('abcd')),
                  //Other options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an Account? ",
                          style: TextStyle(color: blackColor)),
                      TextButton(
                          onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInScreen(),
                                  ),
                                )
                              },
                          child: const Text('SignIn'))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
