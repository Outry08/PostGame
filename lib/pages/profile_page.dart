import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postgame/pages/game_page.dart';
import 'package:postgame/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/pages/post_page.dart';
import 'package:postgame/trackables.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// inspired by https://github.com/JohannesMilke/user_profile_example/blob/master/lib/widget/profile_widget.dart#L22
class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String puid = '';
  String uuid = '';
  int color = 0;
  bool isFollowing = false;

  @override
  void initState() {
    //print("INIT");
    super.initState();
    fetchUserData();
  }

  Future<List<String>> fetchUserData() async {
    var pUserData = await getUserDataFromEmail(widget.email);
    var uUserData = await getUserDataFromEmail(FirebaseAuth.instance.currentUser?.email);
    if (pUserData != null) {
      puid = pUserData['firestoreUser']?["uid"];
    }
    if (uUserData != null) {
      uuid = uUserData['firestoreUser']?["uid"];
    }
    if (pUserData != null) {
      color = pUserData['firestoreUser']?["color"] ?? 0;
    }

    return [uuid, puid];
  }

  bool isEditing = false;
  String _bio_ = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUserData(),
      builder: (context, snapshot) {
        var idList = snapshot.data;
        uuid = (idList != null ? idList[0] : "");
        puid = (idList != null ? idList[1] : "");

        //print(puid + uuid);

        return Scaffold(
            backgroundColor: context.read<PostGameProvider>().secondaryColor,
            appBar: AppBar(
              backgroundColor: context.read<PostGameProvider>().secondaryColor,
              leading: puid != uuid
                  ? IconButton(
                      icon: Icon(Icons.arrow_back, color: context.read<PostGameProvider>().oppColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  : null,
              automaticallyImplyLeading: false,
              actions: uuid == puid
                  ? [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Material(
                          color: context.read<PostGameProvider>().accentColor2,
                          borderRadius: BorderRadius.circular(12),
                          child: IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: context.read<PostGameProvider>().oppColor,
                            ),
                            onPressed: () {
                              signOut();
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            iconSize: 30,
                          ),
                        ),
                      ),
                    ]
                  : [],
            ),
            body: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Center(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: buildProfile(color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                buildName(context),
                const SizedBox(height: 5),
                if (uuid != puid) buildFollowButton(context),
                const SizedBox(height: 10),
                buildFavourites(context),
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Posts:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: context.read<PostGameProvider>().oppColor,
                        ),
                      ),
                      buildPosts(),
                    ],
                  ),
                )
              ],
            ),
            bottomNavigationBar: Navbar());
      },
    );
  }

  Widget buildName(BuildContext context) => Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
              future: getUserDataFromEmail(widget.email),
              builder: (context, snapshot) {
                final displayName = snapshot.data?["firestoreUser"]?["displayName"] as String?;
                return Text(
                  "$displayName",
                  style: TextStyle(
                    fontSize: 36,
                    color: context.read<PostGameProvider>().oppColor,
                  ),
                );
              }),
          const SizedBox(height: 4),
          FutureBuilder<Map<String, dynamic>?>(
              future: getUserDataFromEmail(widget.email),
              builder: (context, snapshot) {
                final uid = snapshot.data?["firestoreUser"]?["uid"] as String?;
                return Text(
                  "@$uid",
                  style: TextStyle(
                    fontSize: 18,
                    color: context.read<PostGameProvider>().accentColor3,
                  ),
                );
              }),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, dynamic>?>(
            future: getUserDataFromEmail(widget.email),
            builder: (context, snapshot) {
              String bio = snapshot.data?["firestoreUser"]?["bio"] as String? ?? "N/A";
              if (uuid == puid) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    TextEditingController _bioController = TextEditingController(text: bio);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "About Me: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: context.read<PostGameProvider>().oppColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20.0),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.read<PostGameProvider>().primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isEditing) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _bio_.isNotEmpty ? _bio_ : bio,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: context.read<PostGameProvider>().oppColor,
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: context.read<PostGameProvider>().secondaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: context.read<PostGameProvider>().oppColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        iconSize: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                TextField(
                                  controller: _bioController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: "Edit your bio...",
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: context.read<PostGameProvider>().oppColor,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: context.read<PostGameProvider>().oppColor,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                                  cursorColor: context.read<PostGameProvider>().oppColor,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing = false;
                                        });
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: context.read<PostGameProvider>().oppColor,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        //print("New bio: ${_bioController.text}");
                                        updateUserBio(uuid, _bioController.text);
                                        setState(() {
                                          _bio_ = _bioController.text;
                                          isEditing = false;
                                          bio = _bioController.text;
                                        });
                                      },
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: context.read<PostGameProvider>().oppColor,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.read<PostGameProvider>().primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              } else {
                return Text(
                  "About Me: $bio",
                  style: TextStyle(
                    fontSize: 24,
                    color: context.read<PostGameProvider>().oppColor,
                  ),
                );
              }
            },
          )
        ],
      );

  Widget buildSummary(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );

  Widget buildFollowButton(BuildContext context) {
    return FutureBuilder<bool?>(
      future: getUserFollowing(uuid, puid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {

          isFollowing = snapshot.data ?? false;

          return Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFollowing = isFollowing;

                    if (!isFollowing) {
                      followUser(
                        uuid,
                        puid,
                      );
                    } else {
                      unfollowUser(uuid, puid);
                    }
                  });
                },
                child: Text(isFollowing
                    ? "Unfollow"
                    : "Follow"),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget buildFavourites(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Favourite Games:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: context.read<PostGameProvider>().oppColor),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.read<PostGameProvider>().primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FutureBuilder<List<GameModel>>(
              future: getUserTopThreeGames(puid, context.read<PostGameProvider>().igdbResource!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  var favouriteGameModels = snapshot.data!;
                  //print("favouriteGameModels");
                  //print(favouriteGameModels);
                  var favouriteGames = favouriteGameModels.map((game) => buildFavouriteItem(game, context)).toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: favouriteGames,
                  );
                } else {
                  return Text('No favourite games found.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFavouriteItem(GameModel game, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamePage(
              game: game,
            ),
          ),
        ).then((value) {
          setState(() {});
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.network(
            game.cover?.url ?? "https://i.ibb.co/XkS4TkT9/4232ddd3f6f020c46052d7adb87abf97.jpg",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildSummaryItem(String game, String emblemUri, BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(game, style: TextStyle(fontSize: 20, color: context.read<PostGameProvider>().oppColor)),
              Ink.image(
                image: NetworkImage(emblemUri),
                fit: BoxFit.cover,
                width: 50,
                height: 50,
                child: InkWell(onTap: () => {}),
              ),
            ],
          )
        ],
      );

  Widget buildPosts() {
    return SingleChildScrollView(
      child: FutureBuilder<List<Trackable>>(
        future: getOwnTrackables(
          puid,
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
                        'No Posts Have Been Made',
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
    );
  }

  void _openColorPicker(int userColor) {
    Color tempColor = Color(userColor);
    if (puid == uuid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick a color', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF323232),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tempColor,
                labelTextStyle: TextStyle(color: Colors.white),
                labelTypes: const [],
                onColorChanged: (color) {
                  tempColor = color;
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Color(0x10FFFFFF)),
                ),
              ),
              TextButton(
                child: Text('SELECT'),
                onPressed: () {
                  updateUserColor(uuid, tempColor.value);
                  setState(() {});
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Color(0x10FFFFFF)),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildProfile(int userColor) {
    return GestureDetector(
      onTap: () => _openColorPicker(userColor),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Color(userColor),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(
            Icons.videogame_asset,
            size: 100,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
