import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgame/common.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/firestore.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';

class Multiplayer extends StatefulWidget {
  final GameModel game;

  const Multiplayer({Key? key, required this.game}) : super(key: key);

  @override
  State<Multiplayer> createState() => _MultiplayerState();
}

class _MultiplayerState extends State<Multiplayer> {
  String? reviews;
  String? rating;
  String? userPost;
  String? playtimeHrs;
  String? status;
  String? rank;
  TrackableType? postType = TrackableType.Achievement;
  String errorMsg = '';
  String? uuid = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var uUserData = await getUserDataFromEmail(FirebaseAuth.instance.currentUser?.email);
    if (uUserData != null) {
      uuid = uUserData['firestoreUser']?["uid"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DropdownButtonFormField<TrackableType>(
        value: postType,
        style: TextStyle(color: context.read<PostGameProvider>().oppColor),
        dropdownColor: context.read<PostGameProvider>().primaryColor,
        decoration: InputDecoration(
          labelText: 'Choose A Post Type.',
          labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
        ),
        items: [TrackableType.Achievement, TrackableType.Review, TrackableType.Update].map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
        onChanged: (val) => setState(() => postType = val),
      ),
      SizedBox(height: 20),
      buildCategoryInput(),
      SizedBox(height: 20),
      Padding(
        padding: EdgeInsets.all(9.0),
        child: ElevatedButton(
          onPressed: () async {
            var res = await submitPost({
              'post-type': postType?.index,
              'description': userPost,
              'game-name': widget.game.name,
              'playtime': playtimeHrs,
              'status': status,
              'review': reviews,
              'rating': rating,
              'rank': rank,
              'uid': uuid,
            });

            if (!res) {
              setState(() {
                errorMsg = 'Error creating post. Please try again.';
              });
              return;
            }

            Navigator.pop(context);
          },
          child: Text('Create'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: TextStyle(fontSize: 18),
            backgroundColor: context.read<PostGameProvider>().accentColor,
            foregroundColor: context.read<PostGameProvider>().oppColor,
          ),
        ),
      ),
      if (errorMsg.isNotEmpty)
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red),
          ),
          child: Text(
            errorMsg,
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ]);
  }

  Widget buildCategoryInput() {
    if (postType == TrackableType.Achievement) {
      return TextField(
        maxLength: 10,
        cursorColor: context.read<PostGameProvider>().oppColor,
        style: TextStyle(color: context.read<PostGameProvider>().oppColor),
        decoration: InputDecoration(
          labelText: 'Rank',
          labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
          border: OutlineInputBorder(borderSide: BorderSide()),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
          counterStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
        ),
        onChanged: (value) => setState(() => rank = value),
      );
    } else if (postType == TrackableType.Review) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            value: '⭐',
            dropdownColor: context.read<PostGameProvider>().primaryColor,
            decoration: InputDecoration(
              labelText: TrackableType.Review.name,
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
            ),
            items: ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐']
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    )))
                .toList(),
            onChanged: (val) => setState(() => rating = val),
          ),
          SizedBox(height: 20),
          TextField(
            maxLength: 50,
            cursorColor: context.read<PostGameProvider>().oppColor,
            style: TextStyle(color: context.read<PostGameProvider>().oppColor),
            decoration: InputDecoration(
              labelText: 'Add a comment to your review',
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              border: OutlineInputBorder(borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              counterStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
            ),
            onChanged: (value) => setState(() {
              reviews = value;
              userPost = value;
            }),
          ),
        ],
      );
    } else if (postType == TrackableType.Update) {
      return Column(
        children: [
          TextField(
            maxLength: 5,
            keyboardType: TextInputType.number,
            cursorColor: context.read<PostGameProvider>().oppColor,
            style: TextStyle(color: context.read<PostGameProvider>().oppColor),
            decoration: InputDecoration(
              labelText: 'Playtime (hours)',
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              border: OutlineInputBorder(borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              counterStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
            ),
            onChanged: (value) => setState(() => playtimeHrs = value),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: 'Playing',
            dropdownColor: context.read<PostGameProvider>().primaryColor,
            style: TextStyle(color: context.read<PostGameProvider>().oppColor),
            decoration: InputDecoration(
              labelText: 'Status',
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              border: OutlineInputBorder(borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
            ),
            items: ['Playing', 'Abandoned', 'Taking a Break'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => status = val),
          ),
          SizedBox(height: 20),
          TextField(
            maxLength: 20,
            cursorColor: context.read<PostGameProvider>().oppColor,
            style: TextStyle(color: context.read<PostGameProvider>().oppColor),
            decoration: InputDecoration(
              labelText: 'Give a quick little update.',
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              border: OutlineInputBorder(borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              counterStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
            ),
            onChanged: (value) => setState(() {
              userPost = value;
            }),
          ),
        ],
      );
    }
    return Container();
  }
}
