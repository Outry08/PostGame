import 'package:flutter/material.dart';
import 'package:postgame/igdb/igdbControllers.dart';
import 'package:postgame/igdb/igdb.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/post_page.dart';
import 'package:postgame/pages/game_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<Map<String, List<GameModel>>> categorizedGames;

  @override
  void initState() {
    super.initState();
    categorizedGames = fetchAllCategories(context);
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
      body: FutureBuilder<Map<String, List<GameModel>>>(
        future: categorizedGames,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                buildCategoryRow(context, "Recommended Games:", data["Main Game"] ?? []),
                buildCategoryRow(context, "Trending Games:", data["DLC Addon"] ?? []),
                buildCategoryRow(context, "Newly Released Games:", data["Expansion"] ?? []),
                buildCategoryRow(context, "Upcoming Games:", data["Mod"] ?? []),
                buildCategoryRow(context, "Top Rated Games:", data["Season"] ?? []),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Navbar(),
    );
  }

  Widget buildCategoryRow(BuildContext context, String categoryTitle, List<GameModel> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Text(
            categoryTitle,
            style: TextStyle(
              color: context.read<PostGameProvider>().oppColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: games
                .map((game) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(game: game),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image(
                            height: 100,
                            image: NetworkImage(game.cover?.url ?? "https://i.ibb.co/XkS4TkT9/4232ddd3f6f020c46052d7adb87abf97.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<Map<String, List<GameModel>>> fetchAllCategories(BuildContext context) async {
    Map<String, List<GameModel>> categorizedGames = {};
    TwitchIGDBApi? igdb = context.read<PostGameProvider>().igdbResource;

    if (igdb == null) {
      //print("igdb resource was not properly initialized");
      return categorizedGames;
    }

    final categories = ["Main Game", "DLC Addon", "Expansion", "Mod", "Season"];
    for (var category in categories) {
      var fetchTypes = await getGameTypes(igdb, 'fields id, type; where type = "$category"; limit: 1;');
      if (fetchTypes.isNotEmpty) {
        var type = fetchTypes[0].id;
        var games = await getGames(igdb, 'fields id, name, cover, game_type, first_release_date, summary, game_modes; where game_type = $type; sort rating_count desc; limit 20;');
        categorizedGames[category] = games;
      }
    }
    return categorizedGames;
  }
}
