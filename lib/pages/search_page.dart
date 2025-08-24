import 'package:flutter/material.dart';
import 'package:postgame/main.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/pages/profile_page.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/post_page.dart';
import 'package:postgame/pages/game_page.dart';
import 'package:postgame/igdb/igdbControllers.dart';
import 'package:postgame/igdb/igdb.dart';
import 'firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool searchByGames = true;

  int? beforeDate;
  int? afterDate;

  String query = "";
  String publisher = "";
  void ToggleGamesSearch() {
    setState(() {
      searchByGames = true;
    });
  }

  void ToggleUsersSearch() {
    setState(() {
      searchByGames = false;
    });
  }

  Future<int?> showYearPickerDialog(BuildContext context) async {
    int selectedYear = DateTime.now().year;

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Year"),
        content: SizedBox(
          height: 200,
          width: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              selectedYear = 1958 + index;
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Text(
                (1958 + index).toString(),
                style: TextStyle(fontSize: 20),
              ),
              childCount: DateTime.now().year - 1957,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: context.read<PostGameProvider>().accentColor2,
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: context.read<PostGameProvider>().oppColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              Navigator.pop(context, selectedYear),
              setState(() {
                selectedYear = selectedYear;
              }),
            },
            style: TextButton.styleFrom(
              backgroundColor: context.read<PostGameProvider>().accentColor2,
            ),
            child: Text(
              "Ok",
              style: TextStyle(
                color: context.read<PostGameProvider>().oppColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showFilterPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Search',
            style: TextStyle(color: context.read<PostGameProvider>().oppColor),
          ),
          backgroundColor: context.read<PostGameProvider>().secondaryColor,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Before Release Date', style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.read<PostGameProvider>().accentColor,
                    foregroundColor: context.read<PostGameProvider>().oppColor,
                    iconColor: context.read<PostGameProvider>().oppColor,
                  ),
                  onPressed: () async {
                    int? pickedYear = await showYearPickerDialog(context);

                    Future.delayed(Duration(milliseconds: 100), () {
                      if (pickedYear != null) {
                        setState(() {
                          beforeDate = pickedYear;
                        });
                      }
                    });
                  },
                  child: Text(
                    beforeDate == null ? 'Select Year' : beforeDate!.toString(),
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                  ),
                ),
                SizedBox(height: 10),
                Text('After Release Date', style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.read<PostGameProvider>().accentColor,
                    foregroundColor: context.read<PostGameProvider>().oppColor,
                    iconColor: context.read<PostGameProvider>().oppColor,
                  ),
                  onPressed: () async {
                    int? pickedYear = await showYearPickerDialog(context);

                    if (pickedYear != null) {
                      setState(() {
                        afterDate = pickedYear;
                      });
                    }
                  },
                  child: Text(
                    afterDate == null ? 'Select Year' : afterDate!.toString(),
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(decoration: TextDecoration.underline, color: context.read<PostGameProvider>().oppColor, decorationColor: context.read<PostGameProvider>().oppColor),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: context.read<PostGameProvider>().oppColor),
              onPressed: () async {
                search_getCategorizedGameInfo(context, query);

                await Future.delayed(Duration(milliseconds: 250));
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply',
                style: TextStyle(
                  color: context.read<PostGameProvider>().oppColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<GameModel>> search_getCategorizedGameInfo(BuildContext context, String query) async {
    List<GameModel> listGames = [];

    TwitchIGDBApi? igdb = context.read<PostGameProvider>().igdbResource;

    if (igdb == null) {
      //print("igdb resource was not properly initialized");
      return listGames;
    }

    var games = await getGames(igdb, 'fields id, name, cover, game_type, first_release_date, involved_companies, summary; search "${query}"; limit 100;');
    List<int> coverIds = games.map((game) => game.coverRefId).whereType<int>().toList();

    if (coverIds.isNotEmpty) {
      String coverIdsString = "(${coverIds.join(',')})";
      var covers = await getCovers(igdb, "fields id, url, game; where id = $coverIdsString; limit 500;");

      for (var game in games) {
        game.cover = CoverModel();
        for (var cover in covers) {
          if (game.coverRefId == cover.id) {
            game.cover = cover;
            break;
          }
        }
      }
    }

    for (var game in games) {
      var tempBefore = beforeDate ?? 15000;
      var tempAfter = afterDate ?? 0;
      var tempPublisher = publisher ?? "";

      if (game.year! >= tempAfter && game.year! <= tempBefore) {
        listGames.add(game);
      }
    }

    listGames = listGames.fold<List<GameModel>>([], (uniqueList, game) {
      if (!uniqueList.any((g) => g.name == game.name)) {
        uniqueList.add(game);
      }
      return uniqueList;
    });

    context.read<PostGameProvider>().listGamesSearch = listGames.toSet().toList();

    return listGames;
  }

  Future<List<Map<String, dynamic>>> search_getUsers(BuildContext context, String query) async {
    List<Map<String, dynamic>> users = await searchUsersByUid(query);
    List<Map<String, dynamic>> newUsers = [];

    for (var user in users) {
      user['gamesPlayed'] = await countUserGames(user['uid']);
      newUsers.add(user);
    }

    context.read<PostGameProvider>().listUsersSearch = newUsers;

    return newUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.read<PostGameProvider>().secondaryColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: context.read<PostGameProvider>().tertiaryColor,
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              "https://i.ibb.co/8g1KZj54/Untitled-drawing.png",
              fit: BoxFit.contain,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    cursorColor: context.read<PostGameProvider>().oppColor,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.read<PostGameProvider>().oppColor,
                      ),
                    ),
                    onSubmitted: (value) {
                      search_getCategorizedGameInfo(context, value);
                      search_getUsers(context, value);
                      setState(() {
                        query = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: context.read<PostGameProvider>().accentColor,
                          foregroundColor: context.read<PostGameProvider>().oppColor,
                          iconColor: context.read<PostGameProvider>().oppColor),
                      onPressed: () {
                        showFilterPopup(context);
                      },
                      child: Text('Filter'),
                    ),
                  ),
                ),
              ],
            ),
          )),
      body: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Search By: ",
                    style: TextStyle(fontSize: 16, color: context.read<PostGameProvider>().oppColor),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: searchByGames == false ? context.read<PostGameProvider>().accentColor2 : context.read<PostGameProvider>().accentColor,
                          foregroundColor: context.read<PostGameProvider>().oppColor,
                          iconColor: context.read<PostGameProvider>().oppColor),
                      onPressed: () {
                        ToggleGamesSearch();
                      },
                      child: Text("Games"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: searchByGames == false ? context.read<PostGameProvider>().accentColor : context.read<PostGameProvider>().accentColor2,
                          foregroundColor: context.read<PostGameProvider>().oppColor,
                          iconColor: context.read<PostGameProvider>().oppColor),
                      onPressed: () {
                        ToggleUsersSearch();
                      },
                      child: Text("Users"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: searchByGames ? GameSection() : UserSection()),
        ],
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}

class GameSection extends StatefulWidget {
  const GameSection({Key? key}) : super(key: key);

  @override
  State<GameSection> createState() => _GameSection();
}

class _GameSection extends State<GameSection> {
  @override
  Widget build(BuildContext context) {
    var games = context.watch<PostGameProvider>().listGamesSearch;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.read<PostGameProvider>().primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: context.read<PostGameProvider>().listGamesSearch.isEmpty
                    ? [
                        Container(
                          color: context.read<PostGameProvider>().primaryColor,
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "No Results Found",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : context.read<PostGameProvider>().listGamesSearch.map((game) {
                        return GameCard(
                          title: game.name,
                          year: game.year.toString(),
                          publisher: "", //game.publisher,
                          imagePath: game.cover?.url ?? 'https://atlas-content-cdn.pixelsquid.com/stock-images/8-bit-mario-mdaWkw1-600.jpg',
                          game: game,
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String year;
  final String publisher;
  final String imagePath;
  final GameModel game;

  const GameCard({
    required this.title,
    required this.year,
    required this.publisher,
    required this.imagePath,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamePage(game: game),
          ),
        );
      },
      child: Card(
        color: context.read<PostGameProvider>().secondaryColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image(image: NetworkImage(imagePath), height: 50, width: 50),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.read<PostGameProvider>().oppColor)),
                    if (year.isNotEmpty && year != "-10")
                      Text(
                        'Year: $year',
                        style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                      ),
                    if (publisher.isNotEmpty)
                      Text(
                        'Publisher: $publisher',
                        style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserSection extends StatefulWidget {
  const UserSection({Key? key}) : super(key: key);

  @override
  State<UserSection> createState() => _UserSection();
}

class _UserSection extends State<UserSection> {
  @override
  Widget build(BuildContext context) {
    var users = context.watch<PostGameProvider>().listUsersSearch;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.read<PostGameProvider>().primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: context.read<PostGameProvider>().listUsersSearch.isEmpty
                      ? [
                          Container(
                            padding: EdgeInsets.all(16),
                            color: context.read<PostGameProvider>().primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "No Results Found",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      : users.map<Widget>((user) {
                          return UserCard(
                            username: user['displayName'],
                            email: user['email'],
                            uid: user['uid'],
                            gamesPlayed: user['gamesPlayed'] ?? 0,
                            description: user['bio'] == "" ? "No description available" : user["bio"] ?? 'No description available',
                            imagePath: user['imagePath'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png', // Default image if no image path is found
                            color: user['color'] ?? 0xFF000000,
                          );
                        }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String username;
  final String email;
  final String uid;
  final int gamesPlayed;
  final String description;
  final String imagePath;
  final int color;

  const UserCard({
    required this.username,
    required this.email,
    required this.uid,
    required this.gamesPlayed,
    required this.description,
    required this.imagePath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(email: email),
          ),
        );
      },
      child: Card(
        color: context.read<PostGameProvider>().secondaryColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(color),
                child: Container(
                  child: Icon(
                    Icons.videogame_asset,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(username, style: TextStyle(fontWeight: FontWeight.bold, color: context.read<PostGameProvider>().oppColor)),
                      Text("@$uid", style: TextStyle(color: Color.fromARGB(255, 165, 165, 165))),
                    ]),
                    if (gamesPlayed != -1) Text('Total Games Played: $gamesPlayed', style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
                    Text('Bio: $description', style: TextStyle(color: context.read<PostGameProvider>().oppColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
