// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:password_manager/colors.dart';

List<String> matchQuery = [];
List<Widget> widgetList = [];
List<String> emailList = [
  'mrraza89@gmail.com',
  'm.ali@gmail.com',
  'hassan@gmail.com',
  'ijaz@gmail.com',
  'malikawan23@gmail.com',
  'zahid7007@gmail.com',
  'ali.zouq@gmail.com',
  'habilurehman@gmail.com',
  'faiza890@gmail.com',
  'noor.fatima@gmail.com',
  'umarfarooq@gmail.com',
];
List<String> passwordList = [
  'dfHIhJSDK7854',
  'DFGIhui5576ve',
  '345&@5dhGHGHG',
  'iGFKJ@FDF.coFDm',
  'FD@DGIO.GFcoGm',
  'GDF@:#.comGD',
  'FDDU654^&--.fds',
  'habUSD784NJKN',
  'fDFUa89FDGmDFSUGI',
  'atima@dfdsH09m',
  'rooq(£IHSDgm',
];

class SearchCredentials extends StatefulWidget {
  const SearchCredentials({Key? key}) : super(key: key);

  @override
  State<SearchCredentials> createState() => _SearchCredentialsState();
}

class _SearchCredentialsState extends State<SearchCredentials> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  String userEmail = '';
  String userPassword = '';
  String findPassword = '';
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
        userEmail = ds['User Email'];
        userPassword = ds['User Password'];
      });
      setState(() {
        emailList.add(userEmail);
        passwordList.add(userPassword);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteCredential(id) {
    return FirebaseFirestore.instance
        .collection('Credentials $currentUserEmail')
        .doc(id)
        .delete()
        .then((value) => print('Credential deleted '))
        .catchError((error) => print('Failed to delete Credential $error'));
  }

  Future<void> updateCredential(id) {
    return FirebaseFirestore.instance
        .collection('Credentials $currentUserEmail')
        .doc(id)
        .update({
          'User Email': _emailController.text,
          'User Password': _passwordController.text,
          'Created At': DateTime.now(),
        })
        .then((value) => print('Credential Update by email : $userEmail'))
        .catchError((error) => print('Failed to Update Credential $error'));
  }

  saveCredentials() async {
    final json = {
      'User Email': _emailController.text,
      'User Password': _passwordController.text,
      'Created At': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('Credentials $currentUserEmail')
        .doc()
        .set(json);
    await Fluttertoast.showToast(
      msg: 'Credentials Save Successfully', // message
      toastLength: Toast.LENGTH_SHORT, // length
      gravity: ToastGravity.BOTTOM, // location
      backgroundColor: Colors.green,
    );
  }

  @override
  void initState() {
    super.initState();
    getFirestoreData();
  }

  String? validatePassword(value) {
    if (value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 16) {
      return 'Should be at least 16 characters';
    } else if (value.length > 50) {
      return 'Should not be more than 50 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text.rich(
      //     TextSpan(
      //       text: '', // default text style
      //       children: <TextSpan>[
      //         TextSpan(
      //             text: 'Search ',
      //             style: TextStyle(fontStyle: FontStyle.italic)),
      //         TextSpan(
      //             text: 'Credentials',
      //             style: TextStyle(fontWeight: FontWeight.bold)),
      //       ],
      //     ),
      //   ),
      //   leading: IconButton(
      //       icon: const Icon(Icons.arrow_back),
      //       onPressed: () {
      //         SystemChannels.textInput.invokeMethod('TextInput.hide');
      //         // searchItems.clear();
      //         _searchController.clear();
      //         Navigator.pop(context);
      //       }),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: SizedBox(
                height: 50.0,
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    cursorColor: Colors.white,
                    style: TextStyle(color: whiteColor),
                    decoration: InputDecoration(
                      fillColor: tealColor,
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: whiteColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: tealColor, width: 1.5),
                      ),
                      hintText: 'Search by email',
                      hintStyle: const TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: whiteColor),
                      prefixIcon: Icon(
                        Icons.search,
                        color: whiteColor,
                      ),
                      prefixText: '  ',
                    ),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        findPassword = value;
                      });
                    }
                    // searchQuery,
                    ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: findPassword.isEmpty
                    ? FirebaseFirestore.instance
                        .collection('Credentials $currentUserEmail')
                        .orderBy('Created At', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('Credentials $currentUserEmail')
                        .where('User Email',
                            isGreaterThanOrEqualTo: findPassword)
                        .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: tealColor,
                      strokeWidth: 2.0,
                    ));
                  }
                  if (snapshot.hasData) {
                    final List storedCredentials = [];

                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map id = document.data() as Map<String, dynamic>;
                      storedCredentials.add(id);
//            print('==============================================');
//            print('Document id : ${document.id}');
                      id['id'] = document.id;
                    }).toList();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        storedCredentials.isEmpty
                            ? Text(findPassword.isEmpty
                                ? 'No Credential Save'
                                : 'No Item Find')
                            : Container(),
                        for (int i = 0; i < storedCredentials.length; i++) ...[
                          SwipeActionCell(
                            key: ObjectKey(storedCredentials[i]['Created At']),
                            leadingActions: [
                              SwipeAction(
                                title: "Edit",
                                style:
                                    TextStyle(fontSize: 12, color: whiteColor),
                                color: Colors.green,
                                icon: Icon(Icons.edit, color: whiteColor),
                                onTap: (CompletionHandler handler) async {
                                  print(storedCredentials[i]['id']);
                                  setState(() {
                                    _emailController.text =
                                        storedCredentials[i]['User Email'];
                                    _passwordController.text =
                                        storedCredentials[i]['User Password'];
                                    openDialog(storedCredentials[i]['id']);
                                  });
                                },
                              ),
                            ],
                            trailingActions: [
                              SwipeAction(
                                title: "Delete",
                                style:
                                    TextStyle(fontSize: 12, color: whiteColor),
                                color: Colors.red,
                                icon: Icon(Icons.delete, color: whiteColor),
                                onTap: (CompletionHandler handler) async {
                                  // list.removeAt(index);
                                  print(storedCredentials[i]['id']);
                                  openDeleteDialog(storedCredentials[i]['id'],
                                      storedCredentials[i]['User Email']);
                                  setState(() {});
                                },
                              ),
                            ],
                            child: CustomCard(
                              email: storedCredentials[i]['User Email'],
                              password: storedCredentials[i]['User Password'],
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                  return Center(
                      child: CircularProgressIndicator(
                    color: tealColor,
                    strokeWidth: 2.0,
                  ));
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog('CREATE');
        },
        tooltip: 'Add Credentials',
        child: const Icon(Icons.add),
      ),
    );
  }

  openDialog(String? id) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: Center(
                  child: Text(id == 'CREATE'
                      ? 'Add new Credential'
                      : 'Update Credential')),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: width,
                  height: 185.0,
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0,
                                right: 25.0,
                                bottom: 10.0,
                                top: 10.0),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: blackColor,
                              style: TextStyle(color: blackColor),
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                      BorderSide(color: tealColor, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                      BorderSide(color: tealColor, width: 1.0),
                                ),
                                hintText: 'Enter Email Id',
                                label: Text('Email Id',
                                    style: TextStyle(color: tealColor)),
                                prefixIcon: Icon(
                                  Icons.alternate_email,
                                  color: tealColor,
                                ),
                                prefixText: '  ',
                              ),
                              controller: _emailController,
                              validator: MultiValidator([
                                RequiredValidator(
                                    errorText: 'Please enter email'),
                                EmailValidator(errorText: 'Not a Valid Email'),
                              ]),
                            ),
                          ),
                          //Password Text Field
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, bottom: 10.0),
                            child: TextFormField(
                              obscureText: _obscureText,
                              cursorColor: blackColor,
                              style: TextStyle(color: blackColor),
                              decoration: InputDecoration(
                                isDense: true,

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                hintText: 'Enter Password',
                                label: Text('Password',
                                    style: TextStyle(color: tealColor)),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                      BorderSide(color: tealColor, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                      BorderSide(color: tealColor, width: 1.0),
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
                              controller: _passwordController,
                              validator: validatePassword,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                //CANCEL Button
                TextButton(
                  onPressed: () {
                    _emailController.clear();
                    _passwordController.clear();
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                //CREATE Button
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      id == 'CREATE'
                          ? await saveCredentials()
                          : updateCredential(id);
                      if (id != 'CREATE') {
                        Fluttertoast.showToast(
                          msg: 'Credentials Update Successfully', // message
                          toastLength: Toast.LENGTH_SHORT, // length
                          gravity: ToastGravity.BOTTOM, // location
                          backgroundColor: Colors.green,
                        );
                      }
                      setState(() {
                        _emailController.clear();
                        _passwordController.clear();
                      });
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    }
                  },
                  child: Text(
                    id == 'CREATE' ? 'SAVE' : 'UPDATE',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          },
        ),
      );
  openDeleteDialog(String id, String title) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            var width = MediaQuery.of(context).size.width;
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: const EdgeInsets.only(top: 10.0),
              title: const Center(child: Text('Delete Credential')),
              content: SingleChildScrollView(
                child: Container(
                  width: width,
                  height: 80.0,
                  child: Center(
                      child: Column(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.fade)),
                      ),
                      const Text('Do you want to delete Credential'),
                      const Text('Deleted credential cannot be recovered',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 10,
                              color: Colors.red)),
                    ],
                  )),
                ),
              ),
              actions: [
                //CANCEL Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                //CREATE Button
                TextButton(
                  onPressed: () async {
                    //Delete a task
                    await deleteCredential(id);
                    Fluttertoast.showToast(
                      msg: 'Credential Deleted Successfully', // message
                      toastLength: Toast.LENGTH_SHORT, // length
                      gravity: ToastGravity.BOTTOM, // location
                      backgroundColor: Colors.black,
                    );
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class CustomCard extends StatefulWidget {
  CustomCard({Key? key, required this.email, required this.password})
      : super(key: key);

  String email;
  String password;
  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    password.text = widget.password;
    return GestureDetector(
      child: ListTile(
        title: Text(widget.email),
        subtitle: TextField(
          controller: password,
          enabled: false,
          obscureText: true,
        ),
        trailing: IconButton(
          splashColor: Colors.teal,
          splashRadius: 35.0,
          icon: const Icon(Icons.copy, color: Colors.grey, size: 20.0),
          onPressed: () {
            setState(() {
              final data = ClipboardData(text: widget.password);
              Clipboard.setData(data);
            });
            Fluttertoast.showToast(
              msg: 'Password Copied', // message
              toastLength: Toast.LENGTH_SHORT, // length
              gravity: ToastGravity.BOTTOM, // location
              backgroundColor: Colors.grey,
              timeInSecForIosWeb: 1,
            );
          },
        ),
      ),
    );
  }
}
