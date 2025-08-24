import 'package:flutter/material.dart';
import 'package:postgame/common.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/pages/firestore.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SinglePlayer extends StatefulWidget {
  final GameModel game;

  const SinglePlayer({Key? key, required this.game}) : super(key: key);

  @override
  State<SinglePlayer> createState() => _SinglePlayerState();
}

class _SinglePlayerState extends State<SinglePlayer> {
  String? reviews;
  String? rating;
  String? userPost;
  String? playtimeHrs;
  String? status;
  double? progressVal;
  TrackableType? postType = TrackableType.Progression;
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
        items: [TrackableType.Progression, TrackableType.Review, TrackableType.Update].map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
        onChanged: (val) => setState(() => postType = val),
      ),
      SizedBox(height: 20),
      buildCategoryInput(),
      Padding(
        padding: EdgeInsets.all(9.0),
        child: ElevatedButton(
          onPressed: () async {
            var res = await submitPost({
              'description': userPost,
              'game-name': widget.game.name,
              'playtime': playtimeHrs,
              'post-type': postType?.index,
              'progression': progressVal?.toInt(),
              'review': reviews,
              'rating': rating,
              'status': status,
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
    if (postType == TrackableType.Progression) {
      return Column(
        children: [
          if (progressVal != null)
            Text(
              'Game Progress: ${progressVal?.toInt()}%',
              style: TextStyle(color: context.read<PostGameProvider>().oppColor),
            ),
          Slider(
            value: progressVal ?? 0,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: context.read<PostGameProvider>().oppColor,
            inactiveColor: context.read<PostGameProvider>().primaryColor,
            onChanged: (value) {
              setState(() {
                progressVal = value;
              });
            },
          )
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
            onChanged: (val) => setState(() {
              playtimeHrs = val;
            }),
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
            onChanged: (val) => setState(() {
              status = val;
            }),
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
            onChanged: (val) => setState(() {
              userPost = val;
            }),
          ),
        ],
      );
    } else if (postType == TrackableType.Review) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            value: rating ?? 'choose a rating',
            dropdownColor: context.read<PostGameProvider>().primaryColor,
            decoration: InputDecoration(
              labelText: TrackableType.Review.name,
              labelStyle: TextStyle(color: context.read<PostGameProvider>().oppColor),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.read<PostGameProvider>().oppColor)),
            ),
            items: ['choose a rating', '⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐']
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: context.read<PostGameProvider>().oppColor),
                    )))
                .toList(),
            onChanged: (val) => setState(() {
              rating = val;
            }),
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
              userPost = value;
              reviews = value;
            }),
          ),
        ],
      );
    }
    return Container();
  }
}
