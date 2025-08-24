import 'package:http/http.dart' as http;
import 'dart:convert';

class GameModel {
  final int id;
  final String name;
  final int year;
  final String publisherName;
  final List<dynamic> companies;
  final String releaseDate;
  final String description;

  final int coverRefId;
  final List<int> gameModes;

  CoverModel? cover = null;
  GenreModel? genre = null;
  GameTypeModel? gameType = null;
  PublisherModel? publisher = null;

  GameModel({
    this.id = -1,
    this.name = "",
    this.coverRefId = -1,
    this.year = -1,
    this.publisherName = "",
    this.releaseDate = "",
    this.description = "",
    this.companies = const [],
    this.gameModes = const [],
  });

  set setCover(CoverModel cover) {
    this.cover = cover;
  }

  set setGenre(GenreModel genre) {
    this.genre = genre;
  }

  set setGameType(GameTypeModel gameType) {
    this.gameType = gameType;
  }

  set publisherName(String publisher) {
    this.publisherName = publisher;
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    String year = DateTime.fromMillisecondsSinceEpoch(
                (json['first_release_date'] ?? 2000) * 1000)
            .year
            .toString() ??
        "????";
    String month = (DateTime.fromMillisecondsSinceEpoch(
                            (json['first_release_date'] ?? 2000) * 1000)
                        .month <
                    10
                ? '0'
                : '') +
            DateTime.fromMillisecondsSinceEpoch(
                    (json['first_release_date'] ?? 2000) * 1000)
                .month
                .toString() ??
        "??";
    String day = (DateTime.fromMillisecondsSinceEpoch(
                            (json['first_release_date'] ?? 2000) * 1000)
                        .day <
                    10
                ? '0'
                : '') +
            DateTime.fromMillisecondsSinceEpoch(
                    (json['first_release_date'] ?? 2000) * 1000)
                .day
                .toString() ??
        "??";

    return GameModel(
      id: json['id'] ?? -1,
      name: json['name'] ?? "",
      coverRefId: json['cover'] ?? -1,
      year: DateTime.fromMillisecondsSinceEpoch(
                  (json['first_release_date'] ?? 2000) * 1000)
              .year ??
          -1,
      releaseDate: year + "-" + month + "-" + day,
      description: json['summary'] ?? "",
      gameModes: (json['game_modes'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

class DateFormatter {
  static String formatGameDate(Map<String, dynamic> json) {
    final timestamp = json['first_release_date'] ?? 2000;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class CoverModel {
  final int id;
  final String url;
  final int gameRefId;

  CoverModel(
      {this.id = -1,
      this.url =
          "https://i.ibb.co/XkS4TkT9/4232ddd3f6f020c46052d7adb87abf97.jpg",
      this.gameRefId = -1});

  factory CoverModel.fromJson(Map<String, dynamic> json) {
    return CoverModel(
      id: json['id'] ?? -1,
      url: json['url'] ??
          "https://i.ibb.co/XkS4TkT9/4232ddd3f6f020c46052d7adb87abf97.jpg",
      gameRefId: json['game'] ?? -1,
    );
  }
}

class InvolvedCompaniesModel {
  final int companyId;
  final bool publisher;

  InvolvedCompaniesModel({this.publisher = false, this.companyId = -1});

  factory InvolvedCompaniesModel.fromJson(Map<String, dynamic> json) {
    return InvolvedCompaniesModel(
        publisher: json['publisher'] ?? false,
        companyId: json['company'] ?? -1);
  }
}

class PublisherModel {
  final String name;
  final int companyId;

  PublisherModel({this.name = "", this.companyId = -1});

  factory PublisherModel.fromJson(Map<String, dynamic> json) {
    return PublisherModel(
        name: json['name'] ?? "", companyId: json['changed_company_id'] ?? -1);
  }
}

class GenreModel {
  final int id;
  final String name;

  GenreModel({
    this.id = -1,
    this.name = "",
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] ?? -1,
      name: json['name'] ?? "",
    );
  }
}

class GameTypeModel {
  final int id;
  final String type;

  GameTypeModel({
    this.id = -1,
    this.type = "",
  });

  factory GameTypeModel.fromJson(Map<String, dynamic> json) {
    return GameTypeModel(
      id: json['id'] ?? -1,
      type: json['type'] ?? "",
    );
  }
}
