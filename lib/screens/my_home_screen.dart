// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_manager/genrate_random_password/genrate_random_password.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({Key? key}) : super(key: key);

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  TextEditingController passwordController = TextEditingController();
  int passwordLength = 8;
  int minPasswordLength = 8;
  int maxPasswordLength = 50;
  List<bool> isChecked = [true, true, true, true];

  String copy = 'Copy';
  Color color = Colors.black;

  delay() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: TextFormField(
                maxLines: null,
                decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'Generate a password'),
                controller: passwordController,
              ),
            ),
            MaterialButton(
              height: 40.0,
              color: Colors.teal,
              onPressed: () {
                setState(() {
                  passwordController.text = generateRandomPassword(
                      passwordLength,
                      isChecked[0],
                      isChecked[1],
                      isChecked[2],
                      isChecked[3]);
                });
              },
              child: const Text(
                'Generate Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              title: Text.rich(
                TextSpan(
                  text: '', // default text style
                  children: <TextSpan>[
                    const TextSpan(
                        text: 'Password Length ',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                    TextSpan(
                        text: '($passwordLength Characters)',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Slider(
              min: 8,
              max: 50,
              value: passwordLength.toDouble(),
              onChanged: (value) {
                setState(() {
                  passwordLength = value.round();
                  print(passwordLength);
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                splashColor: Colors.teal,
                splashRadius: 35.0,
                icon: Icon(Icons.copy, color: color),
                onPressed: () {
                  setState(() {
                    final data = ClipboardData(text: passwordController.text);
                    Clipboard.setData(data);
                  });
                  if (passwordController.text.isNotEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Password Copied', // message
                      toastLength: Toast.LENGTH_SHORT, // length
                      gravity: ToastGravity.CENTER, // location
                      backgroundColor: Colors.grey,
                      timeInSecForIosWeb: 1,
                    );
                  }
                },
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                splashColor: Colors.teal,
                splashRadius: 35.0,
                icon: Icon(Icons.refresh, color: color),
                onPressed: () {
                  setState(() {
                    passwordController.clear();
                    Fluttertoast.showToast(
                      msg: 'Password Refresh', // message
                      toastLength: Toast.LENGTH_SHORT, // length
                      gravity: ToastGravity.CENTER, // location
                      backgroundColor: Colors.grey,
                      timeInSecForIosWeb: 1,
                    );
                  });
                },
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                splashColor: Colors.teal,
                splashRadius: 35.0,
                icon: Icon(Icons.settings, color: color),
                onPressed: () {
                  modalBottomSheetMenu();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 250.0,
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0))),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                    ),
                    ListTile(
                      leading: Checkbox(
                        value: isChecked[0],
                        activeColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            isChecked[0] = value!;
                          });
                        },
                      ),
                      title: const Text('Uppercase (A-Z)'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Checkbox(
                        value: isChecked[1],
                        activeColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            isChecked[1] = value!;
                          });
                        },
                      ),
                      title: const Text('Lowercase (a-z)'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Checkbox(
                        value: isChecked[2],
                        activeColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            isChecked[2] = value!;
                          });
                        },
                      ),
                      title: const Text('Numbers (0-9)'),
                      dense: true,
                    ),
                    ListTile(
                      leading: Checkbox(
                        value: isChecked[3],
                        activeColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            isChecked[3] = value!;
                          });
                        },
                      ),
                      title: const Text('Symbols (!#£.)'),
                      dense: true,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
