import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Serpapi{
  Future<List<dynamic>> getPlacesWithCoordinate(String coordinates, String q) async{
    String location;
    final url = "https://serpapi.com/search.json?engine=google_maps&q=$q&ll=$coordinates&type=search&api_key=19ce64bb17f32b6f5af87d89564d67987a1bd1d58e4d7cb9bdaeb6bb7be8e412";

    List<dynamic> results = [];

    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> json = convert.jsonDecode(response.body);
    results.addAll(json['local_results']);

    if(json['serpapi_pagination'].containsKey('next')){
      var urlNext = json['serpapi_pagination']['next'];
      Timer.periodic(Duration(milliseconds: 3000), (timer) async {
        var placeNext = await getNextResults(urlNext, timer);
        urlNext = placeNext['serpapi_pagination']['next'];
        results.addAll(placeNext['local_results']);
      });
      return results;
    }else{
      return results;
    }
  }

  Future<Map<String,dynamic>> getNextResults(String url, Timer timer) async{
    var response = await http.get(Uri.parse(url+"&api_key=19ce64bb17f32b6f5af87d89564d67987a1bd1d58e4d7cb9bdaeb6bb7be8e412"));
    Map<String,dynamic> json = convert.jsonDecode(response.body);
    if(!json['serpapi_pagination'].containsKey('next')){
      timer.cancel();
    }
    return json;
  }


}