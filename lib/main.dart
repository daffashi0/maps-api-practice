import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gmap_api/export_excel.dart';
import 'package:flutter_gmap_api/location_service.dart';
import 'package:flutter_gmap_api/serpapi_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  static const _syaamilPos = LatLng(-6.9219895,107.6458414);
  final _prefLocation = _syaamilPos.latitude.toString()+','+_syaamilPos.longitude.toString();
  final _radius = 1500;
  List<Marker> markers = [];
  List<dynamic> listPlaces = [];
  Map<String, dynamic> listDetailPlaces = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: _syaamilPos,
    zoom: 14.4746,
  );

  static const CameraPosition _kSyaamil = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-6.9219895,107.6458414),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final Marker _mSyaamil = const Marker(
      markerId: MarkerId('mSyaamil'),
      position: LatLng(-6.9219895,107.6458414),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "Sygma Media Inovasi")
  );

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchQuery = TextEditingController();
  final TextEditingController _searchTempat = TextEditingController();

  void addMarkers(String markerId, double lat, double lng, String infoTitle){

    setState(() {
      markers.add(Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat,lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: infoTitle)
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: markers.isNotEmpty ? markers.map((e) => e).toSet() : {_mSyaamil},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Row(
                  children: [
                    Expanded(
                        child: Column(
                          children: [
                        TextFormField(
                          controller: _searchQuery,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: "Search Tempat"),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) async{
                            markers = [];
                            var place = await Serpapi().getPlacesWithCoordinate("@-6.9034443,107.5731168,12z", value);
                            _getPlacesSerpapi(place);

                            // Jika Search menggunakan google text
                            // var place = await LocationService().placeFindText(value, _searchTempat.text);
                            // _getPlaceByText(place);
                          },
                        ),
                        TextFormField(
                          controller: _searchTempat,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: "Daerah"),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) async{
                            markers = [];
                            var place = await LocationService().placeFindText(_searchQuery.text, value);
                            _getPlaceByText(place);
                          },
                        )
                      ],
                    )),
                    IconButton(onPressed: () async {
                      markers = [];
                      var place = await LocationService().placeFindText(_searchQuery.text, _searchTempat.text);
                      _getPlaceByText(place);
                    }, icon: const Icon(Icons.search),
                    alignment: Alignment.topRight,)
                  ]
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //Download Google result
          ExportExcel().exportToExcel(listPlaces, listDetailPlaces, _searchQuery.text);
          //Gunakan exportSerpapi jika data diambil dari SerpAPI
        },
        label: const Text('Download Excel'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  void openBottomSheet(){
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: listPlaces.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: Column(
                    children: [
                      Center(child: Text(listPlaces[index]['name'])),
                      Center(child: Text(listDetailPlaces[listPlaces[index]['place_id']]['formatted_phone_number'].toString()))
                    ],
                  ),
                );
              }
          )
        )
    );
  }

  // Google API Search Nearby
  Future<void> _getNearbyPlace(List<dynamic> place) async {
    setState(() {
      markers.add(_mSyaamil);
      listPlaces = place;
    });

    for(int i = 0;i<place.length;i++){
      addMarkers(place[i]['place_id'], place[i]['geometry']['location']['lat'], place[i]['geometry']['location']['lng'], place[i]['name']);
      var placeDetail = await LocationService().getPlaceDetail(place[i]['place_id']);
      setState(() {
        listDetailPlaces[place[i]['place_id']]=placeDetail;
      });
    }
  }

  // Google API Search by Text
  Future<void> _getPlaceByText(List<dynamic> place) async {

    for(int i = 0;i<place.length;i++){
      addMarkers(place[i]['place_id'], place[i]['geometry']['location']['lat'], place[i]['geometry']['location']['lng'], place[i]['name']);
      var placeDetail = await LocationService().getPlaceDetail(place[i]['place_id']);
      setState(() {
        listDetailPlaces[place[i]['place_id']]=placeDetail;

        if(i==40){
          listPlaces.addAll(place);
        };
      });
    }
  }

  Future<void> _getPlacesSerpapi(List<dynamic> place) async {
    for(int i = 0;i<place.length;i++){
      setState(() {
        if(i==place.length-1){
          listPlaces.addAll(place);
          listPlaces.toSet().toList();
        }
      });
    }
  }
  
}