// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:password_manager/authetication/authentication_with_google.dart';
import 'package:password_manager/colors.dart';
import 'package:password_manager/genrate_random_password/genrate_random_password.dart';
import 'package:password_manager/screens/my_home_screen.dart';
import 'package:provider/provider.dart';
import 'forgot_password.dart';
import 'registration_screen.dart';

class SignInScreen extends StatefulWidget {
  static const String id = 'SignInScreen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _obscureText = true;
  bool isValidEmail = false;
  bool _isLoading = false;

  var email = "";
  var password = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  String getUserEmail = '';
  String getUserPassword = '';

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

  readEmailAndPassword() async {
    print('----------------------------------');
    print('User Email and password is reading');
    print('----------------------------------');
    String emailValue = await storage.read(key: 'email') ?? 'NULL';
    String passValue = await storage.read(key: 'password') ?? 'NULL';
    setState(() {
      getUserEmail = emailValue;
      getUserPassword = passValue;
    });
    print('================');
    print(getUserEmail);
    print(getUserPassword);
  }

  @override
  void initState() {
    super.initState();
    readEmailAndPassword();
    // passwordController.text =
    //     generateRandomPassword(16, true, true, true, true);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  userSignIn() async {
    try {
      _isLoading = true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
//______________________________________________________________________//
      print('user credential email : ${userCredential.user?.email}');
      await storage.write(
          key: 'uid',
          value: userCredential.user
              ?.uid); //______________________________________________________________________//
      Fluttertoast.showToast(
        msg: 'User Login Successfully', // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM, // location
        backgroundColor: Colors.green,
      );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomeScreen(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("SignInScreen Build Run");

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tealColor,
                      fontSize: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25.0, bottom: 20.0, top: 20.0),
                    child: TextFormField(
                      onTap: () {
                        if (getUserEmail != 'NULL' &&
                            emailController.text.isEmpty) {
                          modalBottomSheetCredentials();
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: blackColor,
                      style: TextStyle(color: blackColor),
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isLoading ? false : true,
                        // fillColor: tealColor,
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
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Please enter email'),
                        EmailValidator(errorText: 'Not a Valid Email'),
                      ]),
                    ),
                  ),
                  //Password Text Field
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, right: 25.0, bottom: 20.0),
                    child: TextFormField(
                      onTap: () {
                        if (getUserPassword != 'NULL' &&
                            passwordController.text.isEmpty) {
                          modalBottomSheetCredentials();
                        }
                      },
                      obscureText: _obscureText,
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
                        hintText: 'Enter Password',
                        label: Text('Password',
                            style: TextStyle(color: tealColor)),
                        // hintStyle: TextStyle(color: purpleColor),
//                        labelText: 'Password',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: tealColor, width: 1.0),
                        ),
//                        labelStyle: TextStyle(color: defaultUIColor),
                        prefixIcon: Icon(
                          Icons.vpn_key,
                          color: tealColor,
                        ),
                        prefixText: '  ',
                        suffixIcon: GestureDetector(
                          child: _obscureText
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
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      controller: passwordController,
                      validator: validatePassword,
                    ),
                  ),
                  Material(
                    color: tealColor,
                    borderRadius: BorderRadius.circular(30.0),
                    clipBehavior: Clip.antiAlias,
                    child: MaterialButton(
                      minWidth: _isLoading ? 50.0 : 160.0,
                      elevation: 3.0,
                      height: 40.0,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');

                        if (_isLoading) {
                        } else {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isValidEmail = true;
                              email = emailController.text;
                              password = passwordController.text;
                            });
                            userSignIn();
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
                          : Text(
                              'Login',
                              style: TextStyle(
                                color: whiteColor,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ),
                      )
                    },
                    child: const Text(
                      'Forgot Password ?',
                      style: TextStyle(fontSize: 14.0, color: Colors.blue),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account? ",
                          style: TextStyle(color: blackColor)),
                      TextButton(
                          onPressed: () => {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide'),
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                )
                              },
                          child: const Text('Register'))
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      await provider.googleLogIn();
                      await Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomeScreen(),
                          ),
                          (route) => false);
                      await Fluttertoast.showToast(
                        msg: 'User Login Successfully', // message
                        toastLength: Toast.LENGTH_SHORT, // length
                        gravity: ToastGravity.BOTTOM, // location
                        backgroundColor: Colors.green,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: whiteColor,
                      onPrimary: blackColor,
                      minimumSize: const Size(200, 50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/google-logo.png', height: 30.0),
                        const SizedBox(
                          width: 5.0,
                        ),
                        const Text('SignIn with Google'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  modalBottomSheetCredentials() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 150.0,
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                      child: Container(
                        width: 200,
                        height: 5.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        getUserEmail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        '******************',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        emailController.text = getUserEmail;
                        passwordController.text = getUserPassword;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: whiteColor,
                        onPrimary: blackColor,
                        minimumSize: const Size(200, 50),
                      ),
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Get Credentials'),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
