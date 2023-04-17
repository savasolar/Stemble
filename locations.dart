import 'package:flutter/material.dart';
import 'package:flutter102/pages/player.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationsPage extends StatefulWidget {

  //this is where the page will be expecting arguments when it's called.

  final int compositionID;

  final String customFilePath01;
  final String customFilePath02;
  final String customFilePath03;
  final String customFilePath04;

  LocationsPage({
    Key? key,
    required this.compositionID,
    required this.customFilePath01,
    required this.customFilePath02,
    required this.customFilePath03,
    required this.customFilePath04,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LocationsPageState();
  }
}

class _LocationsPageState extends State<LocationsPage> {

  //this is where some data that's passed on to the next page might be initialized.

  MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentPosition();
    Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentPosition();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _getCurrentPosition() async {
    Position position = await _determinePosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      //if map's current location is 0, 0
      if (_mapController.center == LatLng(0, 0)) {
        _mapController.move(_currentPosition, 16);
      }
    });
  }

  double p1x = 0.000000;
  double p1y = 0.000000;
  double p2x = 0.000000;
  double p2y = 0.000000;
  double p3x = 0.000000;
  double p3y = 0.000000;
  double p4x = 0.000000;
  double p4y = 0.000000;

  int markerCounter = 0;

  List<Marker> markers = [];

  void _handleTap(LatLng latLng) {

    if(markerCounter < 4) {
      setState(() {
        markers.add(
          Marker(
            point: latLng,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: (context) {
              return Transform.translate(
                offset: Offset(-10, -22),
                child: IconButton(
                  iconSize: 40,
                  onPressed: () {},
                  icon: Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(width: 2, color: Colors.white),
                    //   shape: BoxShape.circle,
                    // ),
                    child: Icon(Icons.music_note, color: Colors.deepPurple),
                  ),
                ),
              );
            },
          ),
        );
      });
      markerCounter++;
    }

    if(markerCounter == 1) {
      p1x = latLng.longitude.toDouble();
      p1y = latLng.latitude.toDouble();
    }
    if(markerCounter == 2) {
      p2x = latLng.longitude.toDouble();
      p2y = latLng.latitude.toDouble();
    }
    if(markerCounter == 3) {
      p3x = latLng.longitude.toDouble();
      p3y = latLng.latitude.toDouble();
    }
    if(markerCounter == 4) {
      p4x = latLng.longitude.toDouble();
      p4y = latLng.latitude.toDouble();
    }

  }

  void _deleteLastMarker() {
    setState(() {
      if (markers.isNotEmpty) {
        markers.removeLast();
      }
    });
    markerCounter--;
  }

  void _deleteAllMarkers() {
    setState(() {
      markers.clear();
    });
    markerCounter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        title: Text('Pick locations fer song #${widget.compositionID}'),
//        title: markerCounter == 4 ? Text('Set Locations (✓)') : Text('Set Locations (${4 - markerCounter} Remaining)'),//Text('Set Locations: (${4 - markerCounter} Left)'),
        title: Text('Set Locations: ($markerCounter/4)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onTap: _handleTap,
                  center: _currentPosition,
                  zoom: 16,
                  maxZoom: 18,
                ),
                layers: [
                  TileLayerOptions(
//                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                    urlTemplate: 'https://mt.google.com/vt/lyrs=h&x={x}&y={y}&z={z}',
                    urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      ...markers,
                    Marker(
                      point: _currentPosition,
                      builder: (context) => Container(
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   border: Border.all(
                        //     width: 3,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        child: Icon(
                          Icons.person,
                          color: Colors.amber,
                          size: 40,
                        ),
                      ),
                    ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: Offset(0, -4), // Default x and y offset of the shadow
                    blurRadius: 2.0,// changes position of shadow
//                    spreadRadius: 1,
                  ),
                ],
                color: Colors.white,
              ),
              child: ButtonBarTheme(
                data: const ButtonBarThemeData(
                  buttonPadding: EdgeInsets.all(20.0),

                ),
                child: ButtonBar(
    //                mainAxisSize: mainAxisSize.min,
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.location_searching),
                      tooltip: 'Re-center map',
                      onPressed: () {
                        _mapController.move(_currentPosition, 16);
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.delete),
                      color: markerCounter > 0 ? Colors.black : Colors.grey,
                      tooltip: 'Clear',
                      onPressed: () {
                        _deleteAllMarkers();
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.restore),
                      color: markerCounter > 0 ? Colors.black : Colors.grey,
                      tooltip: 'Undo',
                      onPressed: () {
                        _deleteLastMarker();
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.play_arrow),
                      color: markerCounter == 4 ? Colors.black : Colors.grey,
                      tooltip: 'Play',
                      onPressed: () {
                        //yea bruv. yea
                        if(markerCounter == 4) {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) =>
                                PlayerPage(
                                  compositionID: widget.compositionID,
                                  p1x: p1x,
                                  p1y: p1y,
                                  p2x: p2x,
                                  p2y: p2y,
                                  p3x: p3x,
                                  p3y: p3y,
                                  p4x: p4x,
                                  p4y: p4y,
                                  customFilePath01: widget.customFilePath01,
                                  customFilePath02: widget.customFilePath02,
                                  customFilePath03: widget.customFilePath03,
                                  customFilePath04: widget.customFilePath04,
                                )
                              ),
                            );
                          }
                          else {
                            null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
      )
    );
  }
}