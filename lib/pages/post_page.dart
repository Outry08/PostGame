import 'dart:io';

import 'package:flutter/material.dart';
import 'package:postgame/common.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:postgame/templates/template_frame.dart';
import 'package:provider/provider.dart';
import 'package:postgame/navbar.dart';

class PostPage extends StatefulWidget {
  final GameModel game;

  PostPage({required this.game});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  GameModes? selectedGameMode = GameModes.SinglePlayer;

  @override
  Widget build(BuildContext context) {
    bool isDark = context.watch<PostGameProvider>().isDark;
    return Scaffold(
        backgroundColor: context.read<PostGameProvider>().secondaryColor,
        appBar: AppBar(
          foregroundColor: context.read<PostGameProvider>().oppColor,
          backgroundColor: context.read<PostGameProvider>().secondaryColor,
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
              SizedBox(height: 30),
              buildRadioSelectionGameModes(),
              SizedBox(height: 45),
              TemplateFrame(
                selectGameMode: selectedGameMode,
                game: widget.game,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Navbar());
  }

  Widget buildRadioSelectionGameModes() {
    var gameModes = widget.game.gameModes;

    var validGameModes = gameModes.where((gm) {
      try {
        GameModes.values[gm - 1];
        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    if (gameModes.isEmpty) {
      return Container();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: validGameModes.map((gm) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Radio<GameModes>(
                  value: GameModes.values[gm - 1],
                  groupValue: selectedGameMode,
                  onChanged: (GameModes? value) {
                    setState(() {
                      selectedGameMode = value;
                    });
                  },
                ),
                Text(
                  GameModes.values[gm - 1].toDisplayString(),
                  style: TextStyle(
                    color: context.read<PostGameProvider>().oppColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
