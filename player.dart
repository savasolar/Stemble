import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;


class PlayerPage extends StatefulWidget {

  //this is where the page will be expecting some arguments.

  final int compositionID;

  final double p1x;
  final double p1y;
  final double p2x;
  final double p2y;
  final double p3x;
  final double p3y;
  final double p4x;
  final double p4y;

  final String customFilePath01;
  final String customFilePath02;
  final String customFilePath03;
  final String customFilePath04;

  PlayerPage({
    Key? key,
    required this.compositionID,
    required this.p1x,
    required this.p1y,
    required this.p2x,
    required this.p2y,
    required this.p3x,
    required this.p3y,
    required this.p4x,
    required this.p4y,
    required this.customFilePath01,
    required this.customFilePath02,
    required this.customFilePath03,
    required this.customFilePath04,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerPageState();
  }

}

class _PlayerPageState extends State<PlayerPage> {

  final playerA = AudioPlayer();
  final playerB = AudioPlayer();
  final playerC = AudioPlayer();
  final playerD = AudioPlayer();

  double userx = 0.000000;
  double usery = 0.000000;

  double p1x = 0.000000;
  double p1y = 0.000000;
  double p2x = 0.000000;
  double p2y = 0.000000;
  double p3x = 0.000000;
  double p3y = 0.000000;
  double p4x = 0.000000;
  double p4y = 0.000000;

  double p1vol = 0;
  double p2vol = 0;
  double p3vol = 0;
  double p4vol = 0;

  double p1userDistance = 0;
  double p2userDistance = 0;
  double p3userDistance = 0;
  double p4userDistance = 0;

  double maxDistance = 0;

  MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(0, 0);


  bool _isPlaying = false;
  double _sliderValue = 0.0;


  //---------------------------------------------------------------




  @override
  void initState() {
    super.initState();

    setStems();

    _mapController = MapController();
    _getCurrentPosition();
    Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentPosition();
      updateStemVolume();

    });

    p1x = widget.p1x; p1y = widget.p1y;
    p2x = widget.p2x; p2y = widget.p2y;
    p3x = widget.p3x; p3y = widget.p3y;
    p4x = widget.p4x; p4y = widget.p4y;

    // Set listeners
    playerD.positionStream.listen((position) {
      setState(() {
        _sliderValue = position.inMilliseconds.toDouble();
      });
    });
    playerD.playerStateStream.listen((playerState) {
      setState(() {
        _isPlaying = playerState.playing;
      });
    });
    print("App has started");
  }

  //possibly combine this with setStems()
  //made to try to account for large wav file sizes
  Future<void> playAudioFromZip() async {
    final bytes = await rootBundle.load('assets/waves.zip');
    final archive = ZipDecoder().decodeBytes(bytes.buffer.asUint8List());
    final wavFile = archive.firstWhere((file) => file.name == 'Stem01.wav');

    final player = AudioPlayer();
    await player.setFilePath('${wavFile.name}');
    await player.play();
  }


  void setStems() {
    if(widget.compositionID == 1) {
      playerA.setAsset('assets/RFJ_STEM_01.m4a');
      playerB.setAsset('assets/RFJ_STEM_02.m4a');
      playerC.setAsset('assets/RFJ_STEM_03.m4a');
      playerD.setAsset('assets/RFJ_STEM_04.m4a');
      print("stems have been set");
   } else if(widget.compositionID == 2) {
      playerA.setAsset('assets/FGJ_STEM_01.m4a');
      playerB.setAsset('assets/FGJ_STEM_02.m4a');
      playerC.setAsset('assets/FGJ_STEM_03.m4a');
      playerD.setAsset('assets/FGJ_STEM_04.m4a');
     print("stems have been set");
    } else if(widget.compositionID == 3) {
      playerA.setFilePath(widget.customFilePath01);
      playerB.setFilePath(widget.customFilePath02);
      playerC.setFilePath(widget.customFilePath03);
      playerD.setFilePath(widget.customFilePath04);
      print("stems have been set");
    }
  }

  void stopEverythingDammit() async {
    await playerA.stop();
    await playerB.stop();
    await playerC.stop();
    await playerD.stop();
  }

  @override
  void dispose() {
    stopEverythingDammit();
    super.dispose();
  }

  //roiit yea

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  void _getCurrentPosition() async {
    Position position = await _determinePosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      userx = _currentPosition.longitude;
      usery = _currentPosition.latitude;
      //if map's current location is 0, 0
      if (_mapController.center == LatLng(0, 0)) {
        _mapController.move(_currentPosition, 16);
      }
    });
  }

  double euclidianDistance(x1, y1, x2, y2) {
    return sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2));
  }

  double calculateMaxDistance(List<double> xCoords, List<double> yCoords) {
    double maxDistance = 0.0;
    for (int i = 0; i < xCoords.length - 1; i++) {
      for (int j = i + 1; j < xCoords.length; j++) {
        double distance = sqrt(pow(xCoords[j] - xCoords[i], 2) + pow(yCoords[j] - yCoords[i], 2));
        if (distance > maxDistance) {
          maxDistance = distance;
        }
      }
    }
    return maxDistance;
  }

  double calculateMaxDistanceFromFourPoints(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
    List<double> xCoords = [x1, x2, x3, x4];
    List<double> yCoords = [y1, y2, y3, y4];
    return calculateMaxDistance(xCoords, yCoords);
  }

  void updateStemVolume() async {
    p1userDistance = euclidianDistance(userx, usery, p1x, p1y);
    p2userDistance = euclidianDistance(userx, usery, p2x, p2y);
    p3userDistance = euclidianDistance(userx, usery, p3x, p3y);
    p4userDistance = euclidianDistance(userx, usery, p4x, p4y);

    maxDistance = calculateMaxDistanceFromFourPoints(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y);

    p1vol = ((1 - p1userDistance / maxDistance) *  (1 - 0.1)) + 0.1;
    p2vol = ((1 - p2userDistance / maxDistance) *  (1 - 0.1)) + 0.1;
    p3vol = ((1 - p3userDistance / maxDistance) *  (1 - 0.1)) + 0.1;
    p4vol = ((1 - p4userDistance / maxDistance) *  (1 - 0.1)) + 0.1;

    // Apply logarithmic function to adjust volume logarithmically
    p1vol = log(p1vol + 1) / log(e + 1);
    p2vol = log(p2vol + 1) / log(e + 1);
    p3vol = log(p3vol + 1) / log(e + 1);
    p4vol = log(p4vol + 1) / log(e + 1);

    //maybe remove the 'await's
    // await playerA.setVolume(p1vol);
    // await playerB.setVolume(p2vol);
    // await playerC.setVolume(p3vol);
    // await playerD.setVolume(p4vol);

    playerA.setVolume(p1vol);
    playerB.setVolume(p2vol);
    playerC.setVolume(p3vol);
    playerD.setVolume(p4vol);
  }

  void _playPause() {
    //maybe force files to re-sync here

    if (_isPlaying == false) {
      playerA.play();
      playerB.play();
      playerC.play();
      playerD.play();
      _isPlaying = true;
      print("All players started playing");
    } else if (_isPlaying == true) {
      playerA.pause();
      playerB.pause();
      playerC.pause();
      playerD.pause();
      _isPlaying = false;
      print("All players paused");
    }
  }

  void _setSliderPosition(double value) {
    setState(() {
      _sliderValue = value;
    });
    final newPosition = Duration(milliseconds: value.toInt());
    playerA.seek(newPosition);
    playerB.seek(newPosition);
    playerC.seek(newPosition);
    playerD.seek(newPosition);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(''),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
//                      onTap: () {},
                    center: _currentPosition,
                    zoom: 16,
                    maxZoom: 18,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.png',//watercolor?
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          point: LatLng(p1y, p1x),
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
                        Marker(
                          point: LatLng(p2y, p2x),
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
                        Marker(
                          point: LatLng(p3y, p3x),
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
                        Marker(
                          point: LatLng(p4y, p4x),
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
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.replay_5),
                  color: Colors.black,
                  onPressed: () {
                    //currently used for debugging
                    print(widget.customFilePath01);
                    print(widget.customFilePath02);
                    print(widget.customFilePath03);
                    print(widget.customFilePath04);
                  },
                ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    //icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      _playPause();
                    },
                  ),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.forward_5),
                  color: Colors.black,
                  onPressed: () {
                    //currently used for debugging
                    print('PlayerA Pos: ${playerA.position.inMilliseconds}');
                    print('PlayerB Pos: ${playerB.position.inMilliseconds}');
                    print('PlayerC Pos: ${playerC.position.inMilliseconds}');
                    print('PlayerD Pos: ${playerD.position.inMilliseconds}');
                  },
                ),
              ],
            ),
        ),

        ),

              //SizedBox(height: 16),
              StreamBuilder<Duration>(
                stream: playerA.durationStream.transform(StreamTransformer.fromHandlers(
                  handleData: (Duration? duration, EventSink<Duration> sink) {
                    if (duration != null) {
                      sink.add(duration);
                    }
                  },
                )),
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return Slider(
                    value: _sliderValue,
                    onChanged: (double value) {
                      _setSliderPosition(value);
                    },
                    max: duration.inMilliseconds.toDouble(),
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey,
                  );
                },
              ),
              //SizedBox(height: 8),
              StreamBuilder<Duration>(
                stream: playerA.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Text(
                    '${_formatDuration(position)} / ${_formatDuration(playerA.duration ?? Duration.zero)}',
                  );
                },
              ),
              SizedBox(height: 16),





            ],
          )
        )
    );
  }
}
