import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'firestore.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _uid = "";
  String _displayName = "";
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    //Retrieve dark mode
    bool isDark = context.watch<PostGameProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: context.read<PostGameProvider>().oppColor,
        backgroundColor: context.read<PostGameProvider>().tertiaryColor,
        title: Text(
          "PostGame",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: context.read<PostGameProvider>().secondaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(children: [
          Image.network("https://i.ibb.co/8g1KZj54/Untitled-drawing.png", height: 150),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text("Email:", style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text("Password:", style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    obscureText: true,
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text("Confirm Password:", style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    obscureText: true,
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text("Unique Handle:", style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _uid = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text("Display Name:", style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: PostGameProvider().oppColor)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _displayName = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PostGameProvider().accentColor, foregroundColor: PostGameProvider().oppColor, iconColor: PostGameProvider().oppColor),
              child: Text('Create Account', style: TextStyle(color: PostGameProvider().oppColor)),
              onPressed: () async {
                if (await validate_form_fields() == false) {
                  return;
                }

                try {
                  await createUser(_email, _password, _uid, _displayName);
                  Navigator.pushNamed(context, '/login');
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMessage = e.message.toString();
                  });
                }
              },
            ),
            SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                'I Already Have An Account',
                style: TextStyle(decoration: TextDecoration.underline, color: PostGameProvider().oppColor, decorationColor: PostGameProvider().oppColor),
              ),
            )
          ])
        ]),
      ),
    );
  }

  Future<bool> validate_form_fields() async {
    String msg = "";
    if (_email == "") {
      msg = "Please enter an email.\n";
    }
    if (_password == "") {
      msg = "Please enter a password.\n";
    }
    if (_confirmPassword == "") {
      msg = "Please confirm your password.\n";
    }
    if (_uid == "" || await isHandleUnique(_uid) == false) {
      msg = "Please enter a unique handle.\n";
    }
    if (_displayName == "") {
      msg = "Please enter a display name.\n";
    }
    if (_password != _confirmPassword) {
      msg = "Password does not match.\n";
    }

    if (msg.isEmpty) {
      return true;
    }

    setState(() {
      _errorMessage = msg;
    });

    return false;
  }
}
