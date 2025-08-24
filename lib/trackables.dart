import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:postgame/common.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:provider/provider.dart';
import 'package:postgame/pages/profile_page.dart';

class RatingTrackable extends Trackable {
  @override
  final String username;
  @override
  final String userProfileUrl;
  @override
  final String game;
  @override
  final Color profileColor;
  @override
  final DateTime date;

  final String rating;

  final String reviewDescription;

  RatingTrackable({this.username = "", this.userProfileUrl = "", this.game = "", this.reviewDescription = "", this.profileColor = Colors.red, required this.date, required this.rating});

  Widget toWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$username rated $game",
          style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 7),
        Text(
          rating,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 12),
        if (reviewDescription.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.comment,
                  color: context.read<PostGameProvider>().oppColor,
                  size: 16,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    reviewDescription,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ProgressionTrackable extends Trackable {
  @override
  final String username;
  @override
  final String userProfileUrl;
  @override
  final String game;
  @override
  final Color profileColor;
  @override
  final DateTime date;

  final int progression;

  ProgressionTrackable({this.username = "", this.userProfileUrl = "", this.game = "", this.profileColor = Colors.red, required this.date, required this.progression});

  Widget toWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$username progressed in $game",
          style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              flex: 85,
              child: Container(
                height: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: LinearProgressIndicator(
                    value: progression / 100,
                    backgroundColor: Colors.grey[600],
                    valueColor: AlwaysStoppedAnimation<Color>(context.read<PostGameProvider>().oppColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "${progression}%",
              style: TextStyle(
                color: context.read<PostGameProvider>().oppColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class UpdateTrackable extends Trackable {
  @override
  final String username;
  @override
  final String userProfileUrl;
  @override
  final String game;
  @override
  final Color profileColor;
  @override
  final DateTime date;

  final String updateDescription;
  final String playtime;
  final String status;

  UpdateTrackable(
      {this.username = "", this.userProfileUrl = "", this.game = "", this.updateDescription = "", this.profileColor = Colors.red, required this.playtime, required this.date, required this.status});

  Widget toWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "$username ${status.toUpperCase()} $game",
                style: TextStyle(
                  color: context.read<PostGameProvider>().oppColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.timer,
              color: context.read<PostGameProvider>().oppColor,
              size: 35,
            ),
            SizedBox(width: 5),
            Text(
              playtime,
              style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 20),
            ),
          ],
        ),
        if (updateDescription.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.update,
                  color: context.read<PostGameProvider>().oppColor,
                  size: 16,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    updateDescription,
                    style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AchievementTrackable extends Trackable {
  @override
  final String username;
  @override
  final String userProfileUrl;
  @override
  final String game;
  @override
  final Color profileColor;
  @override
  final DateTime date;

  final String rank;

  AchievementTrackable({this.username = "", this.userProfileUrl = "", this.game = "", this.profileColor = Colors.red, required this.date, this.rank = ""});

  Widget toWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$username unlocked an achievement in $game",
          style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.emoji_events,
                color: context.read<PostGameProvider>().oppColor,
                size: 35,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  rank,
                  style: TextStyle(color: context.read<PostGameProvider>().oppColor, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

abstract class Trackable {
  // User specific stuff should ideally be it's own class
  abstract final String username;
  abstract final String userProfileUrl;
  abstract final String game;
  abstract final Color profileColor;
  abstract final DateTime date;

  Widget toWidget(BuildContext context);

  Widget trackableWidgetFrame(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: context.read<PostGameProvider>().primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Stack(children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: profileColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: const Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Positioned(
                //   right: 0,
                //   bottom: 0,
                //   child: Container(
                //     height: 20,
                //     width: 20,
                //     decoration: BoxDecoration(
                //       color: context.read<PostGameProvider>().secondaryColor,
                //       borderRadius: BorderRadius.circular(10),
                //       border: Border.all(
                //         color: context.read<PostGameProvider>().oppColor,
                //         width: 1.5,
                //       ),
                //     ),
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(9),
                //       child: Image.network(
                //         'https://api.postgame.app/games/$game/icon',
                //         fit: BoxFit.cover,
                //         errorBuilder: (context, error, stackTrace) => Icon(
                //           Icons.videogame_asset,
                //           color: context.read<PostGameProvider>().oppColor,
                //           size: 12,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ]),
              Text(
                username,
                style: TextStyle(color: context.read<PostGameProvider>().oppColor),
              ),
              Text(
                date.toString().split(" ")[0],
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                date.toString().split(" ")[1].split(":")[0] + ":" + date.toString().split(" ")[1].split(":")[1],
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
            height: 110,
            width: screenWidth - (60 + 20) /*Width of icon*/ - 30 /*margin*/ - 20 /*Screen margin*/ - 72 /*Parent element measurements*/,
            margin: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 10),

            // ----------------------------------------------------------------------------------------------------------
            // ----------------------------------------------------------------------------------------------------------
            // NOTE: injecting the trackable's toWidget here, so that caller can simply use the trackableWidgetFrame
            // ----------------------------------------------------------------------------------------------------------
            // ----------------------------------------------------------------------------------------------------------
            child: toWidget(context)),
        // ----------------------------------------------------------------------------------------------------------
        // ----------------------------------------------------------------------------------------------------------
        // ----------------------------------------------------------------------------------------------------------
        // ----------------------------------------------------------------------------------------------------------
      ]),
    );
  }
}
