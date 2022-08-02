import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String userEmail = '';
  String userPassword = '';
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

  @override
  void initState() {
    super.initState();
    getFirestoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'Search ',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              TextSpan(
                  text: 'Credentials',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              // searchItems.clear();
              _searchController.clear();
              Navigator.pop(context);
            }),
      ),
      body: Stack(
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
                onChanged: searchQuery,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 90.0),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0)),
                ),
                child: matchQuery.length == 0
                    ? ListView.builder(
                        itemCount: emailList.length,
                        itemBuilder: (context, index) {
//                      print(onTextSearch);
                          var item = emailList[index];
                          var pass = passwordList[index];
                          return CustomCard(
                            email: item,
                            password: pass,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: matchQuery.length,
                        itemBuilder: (context, index) {
//                      print(onTextSearch);
                          var item = matchQuery[index];
                          var pass = passwordList[index];
                          return CustomCard(
                            email: item,
                            password: pass,
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void searchQuery(String query) {
    final suggestions = emailList.where(
      (element) {
        final title = element.toLowerCase();
        final input = query.toLowerCase();

        return title.contains(input);
      },
    ).toList();

    setState(() {
      matchQuery = suggestions;
    });
  }
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
