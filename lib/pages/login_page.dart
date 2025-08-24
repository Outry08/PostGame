import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";
  String _errorMsg = "";

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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password',
                  style: TextStyle(decoration: TextDecoration.underline, color: context.read<PostGameProvider>().oppColor, decorationColor: context.read<PostGameProvider>().oppColor),
                ),
              ),
            ),
            SizedBox(height: 10),
            if (_errorMsg.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMsg,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: context.read<PostGameProvider>().accentColor, foregroundColor: context.read<PostGameProvider>().oppColor, iconColor: context.read<PostGameProvider>().oppColor),
              child: Text('Login'),
              onPressed: () async {
                if (!isFieldsValid()) {
                  return;
                }
                try {
                  UserCredential user = await logInUser(_email, _password);
                  var uid = await getUidWithEmail(user.user!.email!);
                  Provider.of<PostGameProvider>(context, listen: false)
                      .currUid = uid!;
                  Navigator.pushNamed(context, '/');
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMsg = e.message.toString();
                  });
                }
              },
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/createaccount');
              },
              child: Text(
                'Create An Account',
                style: TextStyle(decoration: TextDecoration.underline, color: context.read<PostGameProvider>().oppColor, decorationColor: context.read<PostGameProvider>().oppColor),
              ),
            ),
          ])
        ]),
      ),
    );
  }

  bool isFieldsValid() {
    String msg = "";
    if (_email.isEmpty) {
      msg = "Email cannot be empty";
    }

    if (_password.isEmpty) {
      msg = "Password cannot be empty";
    }

    if (!msg.isEmpty) {
      setState(() {
        _errorMsg = msg;
      });
      return false;
    }

    return true;
  }
}
