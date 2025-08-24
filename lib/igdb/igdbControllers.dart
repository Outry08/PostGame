import 'package:postgame/igdb/igdb.dart';
import 'package:postgame/igdb/igdbModels.dart';

Future<List<T>> getModels<T>(TwitchIGDBApi igdb, String endpoint,
    String queryBody, T Function(Map<String, dynamic>) fromJson,
    [List<Future<List<T>> Function(List<T>)> transformations =
        const []]) async {
  List<T> modelList = [];
  try {
    final jsonResponse = await igdb.fetchFromIGDB(endpoint, queryBody);
    if (jsonResponse != null) {
      modelList = (jsonResponse as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();

      for (var transform in transformations) {
        modelList = await transform(modelList);
      }
    }
  } on Exception catch (e) {
    print(e);
  }

  return modelList;
}

Future<List<GameModel>> getGames(TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "games";

  List<Future<List<GameModel>> Function(List<GameModel>)> transformations = [
    (games) async {
      List<int> coverids = List<int>.from(games.map((game) => game.coverRefId));
      String coverIdsString = coverids.join(',');

      var covers = await getCovers(igdb,
          "fields id, url, game; where id = ($coverIdsString); limit 500;");

      for (var game in games) {
        game.cover = CoverModel();
        for (var cover in covers) {
          if (game.coverRefId == cover.id) {
            game.cover = cover;
            break;
          }
        }
      }
      return games;
    },
  ];

  return getModels<GameModel>(igdb, endpoint, queryBody,
      (json) => GameModel.fromJson(json), transformations);
}

Future<List<CoverModel>> getCovers(TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "covers";

  return getModels<CoverModel>(
    igdb,
    endpoint,
    queryBody,
    (json) => CoverModel.fromJson(json),
  );
}

Future<List<InvolvedCompaniesModel>> getInvolvedCompanies(
    TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "involved_companies";

  return getModels<InvolvedCompaniesModel>(
    igdb,
    endpoint,
    queryBody,
    (json) => InvolvedCompaniesModel.fromJson(json),
  );
}

Future<List<PublisherModel>> getPublishers(
    TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "companies";

  return getModels<PublisherModel>(
    igdb,
    endpoint,
    queryBody,
    (json) => PublisherModel.fromJson(json),
  );
}

Future<List<GenreModel>> getGenres(TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "genre";

  return getModels<GenreModel>(
    igdb,
    endpoint,
    queryBody,
    (json) => GenreModel.fromJson(json),
  );
}

Future<List<GameTypeModel>> getGameTypes(
    TwitchIGDBApi igdb, String queryBody) async {
  String endpoint = "game_types";

  return getModels<GameTypeModel>(
    igdb,
    endpoint,
    queryBody,
    (json) => GameTypeModel.fromJson(json),
  );
}
