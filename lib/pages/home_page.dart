import 'package:flutter/material.dart';
import 'package:postgame/main.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/pages/firestore.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:postgame/trackables.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var uUserData = await getUserDataFromEmail(FirebaseAuth.instance.currentUser?.email);
    if (uUserData != null) {
      context.read<PostGameProvider>().currUid = uUserData['firestoreUser']?["uid"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.read<PostGameProvider>().secondaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: context.read<PostGameProvider>().oppColor,
          backgroundColor: context.read<PostGameProvider>().tertiaryColor,
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              "https://i.ibb.co/8g1KZj54/Untitled-drawing.png",
              fit: BoxFit.contain,
            ),
          ),
          title: Text(
            "PostGame",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<List<Trackable>>(
            future: getFriendsTrackables(
              context.read<PostGameProvider>().currUid,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              return snapshot.data!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 80),
                          Icon(Icons.inbox, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Empty Feed',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: snapshot.data!.map((t) => t.trackableWidgetFrame(context)).toList(),
                    );
            },
          ),
        ),
        bottomNavigationBar: Navbar());
  }
}
