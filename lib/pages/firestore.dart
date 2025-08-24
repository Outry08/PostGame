import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgame/common.dart';
import 'package:postgame/igdb/igdb.dart';
import 'package:postgame/igdb/igdbControllers.dart';
import 'package:postgame/igdb/igdbModels.dart';
import 'package:postgame/postgame_provider.dart';
import 'package:postgame/trackables.dart';
import '../firebase_options.dart';

Future<FirebaseFirestore> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  return firestore;
}

Future<void> createUser(
    String email, String password, String uid, String displayName) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    if (userCredential.user == null) {
      throw Exception('Failed to create user account');
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'created': FieldValue.serverTimestamp(),
        'uid': uid,
        'displayName': displayName,
        'bio': "",
        'color': 0xFF000000,
      });
    } catch (e) {
      await userCredential.user?.delete();
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  } on FirebaseAuthException {
    rethrow;
  } catch (e) {
    throw Exception('Failed to create user: ${e.toString()}');
  }
}

Future<void> followUser(String uid, String uidToFollow) async {
  await FirebaseFirestore.instance.collection('user-following').doc().set({
    'uid': uid,
    'following-uid': uidToFollow,
  });
}

Future<void> unfollowUser(String uid, String uidToFollow) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('user-following')
      .where('uid', isEqualTo: uid)
      .where('following-uid', isEqualTo: uidToFollow)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    var docId = querySnapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('user-following')
        .doc(docId)
        .delete();
  }
}

Future<UserCredential> logInUser(String email, String password) async {
  UserCredential? userCredential = null;
  try {
    userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    print(e.message.toString());
    rethrow;
  } catch (e) {
    print(e);
  }

  if (userCredential == null) {
    throw Exception("Something went wrong. Please try again later.");
  }

  return userCredential;
}

void signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<Map<String, dynamic>?> getAuthUserData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  QuerySnapshot snapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: user.email)
      .limit(1)
      .get();

  Map<String, dynamic> combinedUser = {
    "authUser": user,
    "firestoreUser": snapshot.docs.first.data(),
  };

  return combinedUser;
}

Future<bool?> getUserFollowing(String followerUID, String followingUID) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  QuerySnapshot snapshot = await firestore
      .collection("user-following")
      .where("uid", isEqualTo: followerUID)
      .where("following-uid", isEqualTo: followingUID)
      .limit(1)
      .get();

  return snapshot.docs.isNotEmpty;
}

Future<Map<String, dynamic>?> getUserDataFromEmail(String? email) async {
  print(email);
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;

  print("I AM IN GET USER DATA");

  if (email == '') return null;

  QuerySnapshot snapshot;

  snapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  Map<String, dynamic> combinedUser = {
    "authUser": user,
    "firestoreUser": snapshot.docs.first.data(),
  };

  return combinedUser;
}

Future<Set<String>> getUserGamesFromEmail(String? email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (email == '' || email == null) return {};

  String? uid = await getUidWithEmail(email);

  QuerySnapshot snapshot;

  snapshot = await firestore
      .collection("user-game")
      .where("uid", isEqualTo: uid)
      .get();

  if (snapshot.docs.isEmpty) return {};

  Set<String> docs = snapshot.docs
      .map((doc) => (doc.data() as Map<String, dynamic>)["game-name"] as String)
      .where((name) => name.isNotEmpty)
      .toSet();

  //print(docs);

  return docs;
}

Future<bool> submitPost(Map<String, dynamic> postData) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  var uid = postData['uid'];

  final userPostsRef = firestore.collection("user-posts");
  var postQuery = await userPostsRef
      .where("uid", isEqualTo: uid)
      .where("game-name", isEqualTo: postData['game-name'])
      .where("post-type", isEqualTo: postData['post-type'])
      .get();

  Map<String, dynamic> postDataMap = {
    "deleted": postData['deleted'] ?? false,
    "description": postData['description'] ?? "",
    "game-name": postData['game-name'] ?? "",
    "post-type": postData['post-type'],
    "time-stamp": FieldValue.serverTimestamp(),
    "uid": uid,
  };

  if (postQuery.docs.isNotEmpty) {
    await userPostsRef.doc(postQuery.docs.first.id).update(postDataMap);
  } else {
    await userPostsRef.add(postDataMap);
  }

  Map<String, dynamic> gameData = {
    if (postData['favourite'] != null) 'favourite': postData['favourite'],
    if (postData['game-name'] != null) 'game-name': postData['game-name'],
    if (postData['playtime'] != null) 'playtime': postData['playtime'],
    if (postData['progression'] != null) 'progression': postData['progression'],
    if (postData['rank'] != null) 'rank': postData['rank'],
    if (postData['rating'] != null) 'rating': postData['rating'],
    if (postData['review'] != null) 'review': postData['review'],
    if (postData['status'] != null) 'status': postData['status'],
  };

  final userGameRef = firestore.collection("user-game");
  var query = await userGameRef
      .where("uid", isEqualTo: uid)
      .where("game-name", isEqualTo: postData['game-name'])
      .get();

  if (query.docs.isNotEmpty) {
    await userGameRef.doc(query.docs.first.id).update(gameData);
  } else {
    await userGameRef.add({...gameData, 'uid': uid});
  }

  return true;
}

Future<bool> isHandleUnique(String uid) async {
  final userRef = FirebaseFirestore.instance.collection("users");
  var query = await userRef.where("uid", isEqualTo: uid).get();

  return query.docs.isEmpty;
}

Future<List<Trackable>> getFriendsTrackables(currUid) async {
  List<Trackable> trackables = [];

  final currentUser = FirebaseAuth.instance.currentUser;

  final userProfile = "https://i.ibb.co/RGKHQSZs/fat-tabby-cat.jpg";

  if (currentUser != null) {
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('user-following')
        .where('uid', isEqualTo: currUid)
        .get();

    for (var followDoc in followingSnapshot.docs) {
      final followedUserId = followDoc['following-uid'] as String;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: followedUserId)
          .get();

      var profileColor;

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();

        profileColor =
            userData['color'] != null ? Color(userData['color']) : Colors.red;
      }

      final postsSnapshot = await FirebaseFirestore.instance
          .collection('user-posts')
          .where('uid', isEqualTo: followedUserId)
          .get();

      for (var postDoc in postsSnapshot.docs) {
        final postData = postDoc.data();

        final gameName = postData['game-name'] as String;

        final gameSnapshot = await FirebaseFirestore.instance
            .collection('user-game')
            .where('uid', isEqualTo: followedUserId)
            .where('game-name', isEqualTo: gameName)
            .limit(1)
            .get();

        if (gameSnapshot.docs.isEmpty) {
          continue;
        }

        final gameData = gameSnapshot.docs.first.data();

        var postTypeInt = postData['post-type'] as int;
        var postType = TrackableType.values[postTypeInt];

        Trackable? t;
        switch (postType) {
          case TrackableType.Progression:
            t = ProgressionTrackable(
                username: followedUserId,
                date: (postData['time-stamp'] as Timestamp).toDate(),
                progression: gameData['progression'] as int,
                game: postData['game-name'],
                userProfileUrl: userProfile,
                profileColor: profileColor);
            break;
          case TrackableType.Achievement:
            t = AchievementTrackable(
                username: followedUserId,
                date: (postData['time-stamp'] as Timestamp).toDate(),
                rank: gameData['rank'],
                game: postData['game-name'],
                userProfileUrl: userProfile,
                profileColor: profileColor);
            break;
          case TrackableType.Review:
            t = RatingTrackable(
              username: followedUserId,
              date: (postData['time-stamp'] as Timestamp).toDate(),
              rating: gameData['rating'] as String,
              reviewDescription: gameData['review'] as String,
              game: postData['game-name'] as String,
              userProfileUrl: userProfile,
              profileColor: profileColor,
            );
            break;
          case TrackableType.Update:
            t = UpdateTrackable(
                username: followedUserId,
                date: (postData['time-stamp'] as Timestamp).toDate(),
                playtime: gameData['playtime'],
                status: gameData['status'],
                game: postData['game-name'],
                userProfileUrl: userProfile,
                profileColor: profileColor);
            break;
          case TrackableType.None:
            break;
        }

        if (t != null) {
          trackables.add(t);
        }
      }
    }
  }

  trackables.sort((a, b) => b.date.compareTo(a.date));

  return trackables;
}

Future<List<Trackable>> getOwnTrackables(currUid) async {
  List<Trackable> trackables = [];

  final currentUser = FirebaseAuth.instance.currentUser;

  final userProfile = "https://i.ibb.co/RGKHQSZs/fat-tabby-cat.jpg";

  if (currentUser != null) {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currUid)
        .get();

    var profileColor;

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();

      profileColor =
          userData['color'] != null ? Color(userData['color']) : Colors.red;
    }

    final postsSnapshot = await FirebaseFirestore.instance
        .collection('user-posts')
        .where('uid', isEqualTo: currUid)
        .get();

    for (var postDoc in postsSnapshot.docs) {
      final postData = postDoc.data();

      final gameName = postData['game-name'] as String;

      final gameSnapshot = await FirebaseFirestore.instance
          .collection('user-game')
          .where('uid', isEqualTo: currUid)
          .where('game-name', isEqualTo: gameName)
          .limit(1)
          .get();

      if (gameSnapshot.docs.isEmpty) {
        continue;
      }

      final gameData = gameSnapshot.docs.first.data();

      var postTypeInt = postData['post-type'] as int;
      var postType = TrackableType.values[postTypeInt];

      Trackable? t;

      switch (postType) {
        case TrackableType.Progression:
          t = ProgressionTrackable(
            username: currUid,
            progression: gameData['progression'] as int,
            game: postData['game-name'],
            userProfileUrl: userProfile,
            profileColor: profileColor,
            date: (postData['time-stamp'] as Timestamp).toDate(),
          );
          break;
        case TrackableType.Achievement:
          t = AchievementTrackable(
            username: currUid,
            rank: gameData['rank'],
            game: postData['game-name'],
            userProfileUrl: userProfile,
            profileColor: profileColor,
            date: (postData['time-stamp'] as Timestamp).toDate(),
          );
          break;
        case TrackableType.Review:
          t = RatingTrackable(
            username: currUid,
            rating: gameData['rating'] as String,
            reviewDescription: gameData['review'] as String,
            game: postData['game-name'] as String,
            userProfileUrl: userProfile,
            profileColor: profileColor,
            date: (postData['time-stamp'] as Timestamp).toDate(),
          );
          break;
        case TrackableType.Update:
          t = UpdateTrackable(
            username: currUid,
            playtime: gameData['playtime'],
            status: gameData['status'],
            game: postData['game-name'],
            userProfileUrl: userProfile,
            profileColor: profileColor,
            date: (postData['time-stamp'] as Timestamp).toDate(),
          );
          break;
        case TrackableType.None:
          break;
      }

      if (t != null) {
        trackables.add(t);
      }
    }
  }

  trackables.sort((a, b) => b.date.compareTo(a.date));

  return trackables;
}

Future<List<Map<String, dynamic>>> searchUsersByUid(String query) async {
  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> users = querySnapshot.docs
        .map((doc) => doc.data())
        .where((user) =>
            (user['uid'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();

    return users;
  } catch (e) {
    print('Error fetching users: ${e.toString()}');
    return [];
  }
}

Future<String?> getUidWithEmail(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (email == '') return null;

  QuerySnapshot snapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  String uid = snapshot.docs.first['uid'];
  //print(uid);
  return uid;
}

Future<String?> getEmailWithUid(String uid) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (uid == '') return null;

  QuerySnapshot snapshot = await firestore
      .collection("users")
      .where("uid", isEqualTo: uid)
      .limit(1)
      .get();

  String email = snapshot.docs.first['email'];
  //print(email);
  return email;
}

Future<void> updateUserBio(String uid, String newBio) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(querySnapshot.docs.first.id)
          .update({"bio": newBio});

      //print("Bio updated successfully!");
    } else {
      //print("User with uid $uid not found.");
    }
  } catch (e) {
    print("Error updating bio: $e");
  }
}

Future<void> updateUserColor(String uid, int newColor) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(querySnapshot.docs.first.id)
          .update({"color": newColor});

      //print("Color updated successfully!");
    } else {
      print("User with uid $uid not found.");
    }
  } catch (e) {
    print("Error updating color: $e");
  }
}

Future<int> countUserGames(String uid) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user-game')
        .where('uid', isEqualTo: uid)
        .get();

    return querySnapshot.docs.length;
  } catch (e) {
    print("Error counting games: $e");
    return 0;
  }
}

Future<bool> updateUserFavourite(
    String uid, String gameName, bool isFavourite) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user-game')
        .where('uid', isEqualTo: uid)
        .where('game-name', isEqualTo: gameName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('user-game')
          .doc(querySnapshot.docs.first.id)
          .update({"favourite": isFavourite});
      return true;
    } else {
      await FirebaseFirestore.instance.collection('user-game').add({
        'uid': uid,
        'game-name': gameName,
        'favourite': isFavourite,
      });
      return true;
    }
  } catch (e) {
    print("Error updating favourite: $e");
    return false;
  }
}

Future<bool> isGameFavourite(String uid, String gameName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user-game')
        .where('uid', isEqualTo: uid)
        .where('game-name', isEqualTo: gameName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['favourite'] as bool;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<List<GameModel>> getUserTopThreeGames(
    String currUid, TwitchIGDBApi igdb) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user-game')
        .where('uid', isEqualTo: currUid)
        .where('favourite', isEqualTo: true)
        .limit(3)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<String> gameNames = querySnapshot.docs
          .map((doc) => '"${doc['game-name'] as String}"')
          .toList();

      List<GameModel> games = await getGames(igdb,
          'fields id, name, cover, summary, game_modes; where name = (${gameNames.join(",")}); limit 500;');

      //print("getUserTopThreeGames");
      //print(games);

      games = games.fold<List<GameModel>>([], (uniqueList, game) {
        if (!uniqueList.any((g) => g.name == game.name)) {
          uniqueList.add(game);
        }
        return uniqueList;
      });
      return games;
    } else {
      return [];
    }
  } catch (e) {
    print("Error fetching top three games: $e");
    return [];
  }
}
