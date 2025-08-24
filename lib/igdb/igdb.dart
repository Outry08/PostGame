import 'dart:convert';
import 'package:http/http.dart' as http;

class TwitchIGDBApi {
  final String clientId = "pz235703q4ojngj7xnzm6defup0jcn";
  final String clientSecret = "w6mtg8fle01ehrk3e4089rhro8f1me";
  String? _accessToken;

  Future<void> authenticate() async {
    final Uri url = Uri.parse('https://id.twitch.tv/oauth2/token?'
        'client_id=$clientId&'
        'client_secret=$clientSecret&'
        'grant_type=client_credentials');

    final response = await http.post(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate: ${response.body}');
    }
  }

  Future<dynamic> fetchFromIGDB(String endpoint, String body) async {
    if (_accessToken == null) {
      await authenticate();
    }

    final Uri url = Uri.parse('https://api.igdb.com/v4/$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data: ${response.body}');
    }
  }
}

void testapi() async {
  final api = TwitchIGDBApi();
  await api.authenticate();
  final idreq = await api.fetchFromIGDB('genres', 'fields id,name; where name="Racing";');
  int id = idreq[0]['id'];
  //print(id);

  final gamesreq = await api.fetchFromIGDB('games', 'fields id,name,cover,game_localizations; where genres=$id; sort rating_count desc;');

  final localizationsreq = await api.fetchFromIGDB('game_localizations', 'cover; where genres=${gamesreq[0].game_localizations[0]};');

  //print("length");
  //print(gamesreq.length);
  List<int> coverids = List<int>.from(gamesreq.map((game) => (game['cover'] ? game['cover'] : localizationsreq[0])));
  //print("coverids");
  //print(coverids);
  //print(coverids.length);

  String coverIdsString = coverids.join(',');
  //print(coverIdsString);
  final coverlinksreq = await api.fetchFromIGDB('covers', 'fields id,image_id; where id = ($coverIdsString);');
  //print(coverlinksreq);

  final logos = await api.fetchFromIGDB('company_logos', 'fields alpha_channel,animated,checksum,height,image_id,url,width;');
  //print(logos);
  //https://images.igdb.com/igdb/image/upload/t_cover_big/co209g.webp AS AN EXAMPLE
}
