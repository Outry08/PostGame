import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgame/igdb/igdbControllers.dart';
import 'package:postgame/igdb/igdb.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/post_page.dart';
import 'package:postgame/pages/firestore.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String uuid = '';

  @override
  void initState() {
    //print("INIT");
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var uUserData =
        await getUserDataFromEmail(FirebaseAuth.instance.currentUser?.email);
    if (uUserData != null) {
      uuid = uUserData['firestoreUser']?["uid"];
    }
    getUserGamesFromEmail(FirebaseAuth.instance.currentUser?.email);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<PostGameProvider>().isDark;
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
        body: Center(
          child: FutureBuilder<List<GameModel>>(
            future: getGameInfo(context),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Container(
                        margin: EdgeInsets.only(left: 8),
                        child: Text(
                          "Choose a game to post about:",
                          style: TextStyle(
                              fontSize: 18,
                              color: context.read<PostGameProvider>().oppColor),
                        )),
                    SizedBox(height: 8),
                    Expanded(
                        child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      scrollDirection: Axis.vertical,
                      children: snapshot.data!.map((game) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostPage(game: game)),
                              );
                            },
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image(
                                    image: NetworkImage(game.cover?.url ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                                )));
                      }).toList(),
                    ))
                  ]);
            },
          ),
        ),
        bottomNavigationBar: Navbar());
  }

  Future<List<GameModel>> getGameInfo(BuildContext context) async {
    List<GameModel> listGames = [];

    TwitchIGDBApi? igdb = context.read<PostGameProvider>().igdbResource;

    if (igdb == null) {
      return listGames;
    }

    Set<String> gamesString =
        await getUserGamesFromEmail(FirebaseAuth.instance.currentUser?.email);

    for (var gameName in gamesString) {
      var gameList = await getGames(igdb,
          "fields id, name, cover, game_modes; where name=\"$gameName\"; limit 1;");

      if (gameList.isNotEmpty) {
        listGames.add(gameList[0]);
      }
    }

    return listGames;
  }
}
