import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/firestore.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/navbar.dart';
import 'package:postgame/common.dart';
import 'package:postgame/pages/post_page.dart';

class GamePage extends StatefulWidget {
  final GameModel game;

  GamePage({required this.game});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String? reviews = '';
  String userPost = '';
  TrackableType? postType = TrackableType.Achievement;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    () async {
      isFavourite = await isGameFavourite(
          context.read<PostGameProvider>().currUid, widget.game.name);
      setState(() {});
    }();
  }

  void toggleFavourite() {
    setState(() {
      isFavourite = !isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<PostGameProvider>().isDark;
    return Scaffold(
        backgroundColor: context.read<PostGameProvider>().secondaryColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: context.read<PostGameProvider>().oppColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          foregroundColor: context.read<PostGameProvider>().oppColor,
          backgroundColor: context.read<PostGameProvider>().secondaryColor,
          actions: [
            SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  size: 30,
                  color: isFavourite
                      ? Colors.red
                      : context.read<PostGameProvider>().oppColor,
                ),
                onPressed: () async {
                  toggleFavourite();
                  await updateUserFavourite(
                      context.read<PostGameProvider>().currUid,
                      widget.game.name,
                      isFavourite);
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.network(
                widget.game.cover?.url ?? "",
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text(
                widget.game.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.read<PostGameProvider>().oppColor,
                ),
              ),
              Text(
                "Released: ${widget.game.releaseDate}",
                style: TextStyle(
                  fontSize: 18,
                  color: context.read<PostGameProvider>().oppColor,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: Text(
                  "Description:",
                  style: TextStyle(
                    fontSize: 18,
                    color: context.read<PostGameProvider>().oppColor,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  "${widget.game.description}",
                  style: TextStyle(
                    fontSize: 14,
                    color: context.read<PostGameProvider>().oppColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(9.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostPage(game: widget.game)),
                    );
                  },
                  child: Text('Create Post'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor:
                        context.read<PostGameProvider>().primaryColor,
                    foregroundColor: context.read<PostGameProvider>().oppColor,
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Navbar());
  }

  Widget buildCategoryInput() {
    if (postType == TrackableType.Progression) {
      return Container();
    } else if (postType == TrackableType.Achievement) {
      return Container();
    } else if (postType == TrackableType.Review) {
      return DropdownButtonFormField<String>(
        value: '⭐',
        dropdownColor: context.read<PostGameProvider>().primaryColor,
        decoration: InputDecoration(
          labelText: TrackableType.Review.name,
          labelStyle:
              TextStyle(color: context.read<PostGameProvider>().oppColor),
          focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: context.read<PostGameProvider>().oppColor)),
          enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: context.read<PostGameProvider>().oppColor)),
        ),
        items: ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐']
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(
                      color: context.read<PostGameProvider>().oppColor),
                )))
            .toList(),
        onChanged: (val) => setState(() => reviews = val),
      );
    } else if (postType == TrackableType.Update) {
      return Container();
    }
    return Container();
  }
}
