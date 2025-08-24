import 'package:flutter/material.dart';
import 'package:postgame/pages/create_page.dart';
import 'package:postgame/pages/explore_page.dart';
import 'package:postgame/pages/search_page.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/pages/home_page.dart';
import 'package:postgame/pages/profile_page.dart';
import 'package:postgame/pages/create_account_page.dart';
import 'package:postgame/pages/login_page.dart';
import 'package:postgame/igdb/igdb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final api = TwitchIGDBApi();
  await api.authenticate();
  runApp(ChangeNotifierProvider(
      create: (context) {
        return PostGameProvider(api: api);
      },
      child: PostGame()));
}

class PostGame extends StatelessWidget {
  const PostGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomePage(),
        '/createaccount': (context) =>
            CreateAccountPage(title: "Create Account"),
        '/login': (context) => LoginPage(title: "Login"),
        '/search': (context) => SearchPage(),
        '/create': (context) => CreatePage(),
        '/explore': (context) => ExplorePage(),
        '/profile': (context) => ProfilePage(
            email: (FirebaseAuth.instance.currentUser?.email ?? "hello")),
      },
    );
  }
}
