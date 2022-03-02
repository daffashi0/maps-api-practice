import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class LocationService{
  final String key = 'AIzaSyBhkF2tsDCvHl61HgGTB2ONm5UYqdBo8mU';

  Future<List<dynamic>> getNearbyPlaces(String input, String location, int radius) async {
    String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=$input&location=$location&radius=$radius&key=$key';
    List<dynamic> results = [];

    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> json = convert.jsonDecode(response.body);
    results.addAll(json['results']);

    if(json.containsKey('next_page_token')){
      var pageToken = json['next_page_token'];
      Timer.periodic(Duration(milliseconds: 3000), (timer) async {
        var placeNext = await getNearbyNextPage(pageToken, timer);
        results.addAll(placeNext['results']);
      });
      return results;
    }else{
      return results;
    }
  }

  Future<Map<String, dynamic>> getNearbyNextPage(String token, Timer timer) async{
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$token&key=$key';

    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> json = convert.jsonDecode(response.body);

    if(!json.containsKey('next_page_token')){
      timer.cancel();
    }
    return json;
  }

  Future<Map<String, dynamic>> getPlaceDetail(String placeId) async{
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var result = json['result'] as Map<String, dynamic>;

    return result;
  }

  Future<List<dynamic>> placeFindText(String tempat, String daerah) async{
    final String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$tempat in $daerah&key=$key';

    List<dynamic> results = [];

    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> json = convert.jsonDecode(response.body);
    results.addAll(json['results']);

    if(json.containsKey('next_page_token')){
      var pageToken = json['next_page_token'];
      Timer.periodic(Duration(milliseconds: 3000), (timer) async {
        var placeNext = await placeFindTextNext(pageToken, timer);
        results.addAll(placeNext['results']);
      });
      return results;
    }else{
      return results;
    }
  }

  Future<Map<String,dynamic>> placeFindTextNext(String token, Timer timer) async{
    final String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?pagetoken=$token&key=$key';

    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> json = convert.jsonDecode(response.body);

    if(!json.containsKey('next_page_token')){
      timer.cancel();
    }
    return json;
  }
}