// ignore_for_file: avoid_print

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/colors.dart';

import 'registration_screen.dart';
import 'signIn_screen.dart';

class ForgotPassword extends StatefulWidget {
  static const String id = 'ForgotPassword';
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  bool _isLoading = false;

  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  resetPassword() async {
    try {
      _isLoading = true;
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      await Fluttertoast.showToast(
        msg: 'Email has been sent for Reset Password', // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM, // location
        backgroundColor: Colors.green,
      );
//      ScaffoldMessenger.of(context).showSnackBar(
//        const SnackBar(
//          backgroundColor: Colors.green,
//          content: Text(
//            'Password Reset Email has been sent !',
//            style: TextStyle(fontSize: 10.0, color: Colors.white),
//          ),
//        ),
//      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'No user found for that email.',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("ForgotPassword Bulid Run");
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'Forget Password',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: const Text(
              'Reset Link will be sent to your email address',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        autofocus: false,
                        cursorColor: blackColor,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          isDense: true,
                          enabled: _isLoading ? false : true,
//                          labelText: 'Email',
                          prefixText: '  ',
                          label:
                              Text('Email', style: TextStyle(color: tealColor)),
                          hintText: 'Enter email address',
                          // labelStyle: const TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide:
                                BorderSide(color: tealColor, width: 1.5),
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.red, fontSize: 15),
                        ),
                        controller: emailController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Please enter email'),
                          EmailValidator(errorText: 'Please enter valid email'),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 80.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5.0),
                          backgroundColor: MaterialStateProperty.all(tealColor),
                          minimumSize:
                              MaterialStateProperty.all(const Size(120, 45)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              email = emailController.text;
                            });
                            resetPassword();
                          }
                        },
                        child: _isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 30.0,
                                    width: 30.0,
                                    child: CircularProgressIndicator(
                                      color: whiteColor,
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15.0,
                                  ),
                                  Text(
                                    'Please Wait',
                                    style: TextStyle(
                                      color: whiteColor,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Send Email',
                                style: TextStyle(
                                  color: whiteColor,
                                ),
                              ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have Account? "),
                            TextButton(
                              onPressed: () => {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a, b) =>
                                          const RegisterScreen(),
                                      transitionDuration:
                                          const Duration(seconds: 1),
                                    ),
                                    (route) => false)
                              },
                              child: const Text('Register'),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            TextButton(
                                onPressed: () => {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, a, b) =>
                                                const SignInScreen(),
                                            transitionDuration:
                                                const Duration(seconds: 1),
                                          ),
                                          (route) => false)
                                    },
                                child: const Text('SignIn'))
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
