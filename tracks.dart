import 'package:flutter/material.dart';
import 'package:flutter102/pages/locations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class TracksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TracksPageState();
  }
}

class _TracksPageState extends State<TracksPage> {
  //this is where some page-shared data will be initialized (e.g. int compositionID)

  int compositionID = 0;

  String customFilePath01 = 'booger';
  String customFilePath02 = 'fart';
  String customFilePath03 = 'cum';
  String customFilePath04 = 'shit';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    print('Storage permission status: ${statuses[Permission.storage]}');
  }

  Future<void> pickFiles() async {
    try {
      final files = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        //allowedExtensions: ['wav', 'm4a'],
        allowMultiple: true,
        //maxFiles: 4,
      );
      if (files != null && files.files.length == 4) {
        customFilePath01 = files.files[0].path!;
        customFilePath02 = files.files[1].path!;
        customFilePath03 = files.files[2].path!;
        customFilePath04 = files.files[3].path!;

        //navigate to next page from here.
        nextPage();
      }
    } catch (e) {
      print('Error while picking the file: $e');
    }
  }


  void nextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationsPage(
          compositionID: compositionID,
          customFilePath01: customFilePath01,
          customFilePath02: customFilePath02,
          customFilePath03: customFilePath03,
          customFilePath04: customFilePath04,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    // return Container(
    //     decoration: BoxDecoration(
    //     border: Border.all(
    //     color: Colors.black,
    //     width: 40.0,
    // ),
    // borderRadius: BorderRadius.circular(100.0),
    // ),
    // child: Scaffold(
    //   backgroundColor: Colors.white, //Colors.black,
      //      appBar: AppBar(
      //        title: Text('Pick a composition'),
      //      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
              child: Image.asset(
                'assets/logo.png',
//                width: MediaQuery.of(context).size.width,
//                height: MediaQuery.of(context).size.width,
//                fit: BoxFit.fitWidth,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {

                setState(() {
                  compositionID = 3;
                });


                pickFiles();
              },
              child: Text(
                'Choose files',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                //yea bruv. yea

                setState(() {
                  compositionID = 1;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationsPage(
                      compositionID: compositionID,
                      customFilePath01: customFilePath01,
                      customFilePath02: customFilePath02,
                      customFilePath03: customFilePath03,
                      customFilePath04: customFilePath04,
                    ),
                  ),
                );
              },
              child: Text(
                'Play default',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),

//       body: Container(
//         width: double.infinity,
//         child: Column(
//           children: [
// //            Expanded(
// //              flex: 2,
// //              child: Padding(
//               Padding(
//                 padding: EdgeInsets.only(top: 50, bottom: 0),
//                 child: Image.asset(
//                   'assets/logo.png',
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   width: MediaQuery.of(context).size.width,
//                 ),
//               ),
// //            ),
//
// //            Expanded(
// //              flex: 3,
// //              child: Container(
//               Container(
//                 color: Colors.green,
//                 width: double.infinity,
//                 margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(top: 20, bottom: 20),
//                       child: TextButton(
//                       onPressed: () {
//                         pickFiles();
//                       },
//                         child: Text('Choose files'),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(top: 20, bottom: 20),
//                       child: TextButton(
//                         onPressed: () {
//                           //yea bruv. yea
//
//                           setState(() {
//                             compositionID = 1;
//                           });
//
//                           Navigator.push(context,
//                             MaterialPageRoute(
//                               builder: (context) => LocationsPage(
//                                 compositionID: compositionID,
//                                 customFilePath01: customFilePath01,
//                                 customFilePath02: customFilePath02,
//                                 customFilePath03: customFilePath03,
//                                 customFilePath04: customFilePath04,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Text('Play default'),
//                       ),
//                     ),
//                   ],
// //                ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//           const Padding(
//             padding: EdgeInsets.only(left: 0, top: 100, bottom: 0, right: 0),
//             child: Image(
//               image: AssetImage('assets/STEMBLE.png'),
//               width: 250,
//               height: 100,
//               fit: BoxFit.fitWidth,
//             ),
//           ),
//             TextButton(child: Text('Choose stems from device'),
//               onPressed: () {
//
//                 pickFiles();
//
//               }
//             ),
//               const Image(
//                 image: AssetImage('assets/Remembering_June.jpg'),
//                 width: 200,
//                 height: 200,
//                 fit: BoxFit.fitWidth
//               ),
//               TextButton(child: Text('Listen to Remembering June'),
//                   onPressed: () {
//                     //yea bruv. yea
//
//                     setState(() {
//                       compositionID = 1;
//                     });
//
//                     Navigator.push(context,
//                       MaterialPageRoute(
//                         builder: (context) => LocationsPage(
//                           compositionID: compositionID,
//                           customFilePath01: customFilePath01,
//                           customFilePath02: customFilePath02,
//                           customFilePath03: customFilePath03,
//                           customFilePath04: customFilePath04,
//                         ),
//                       ),
//                     );
//                   }
//               ),
//               const Image(
//                   image: AssetImage('assets/Forgetting_June.jpg'),
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.fitWidth
//               ),
//               TextButton(child: Text('Listen to Forgetting June'),
//                 onPressed: () {
//
//                   setState(() {
//                     compositionID = 2;
//                   });
//
//                   //yea bruv. yea
//                   Navigator.push(context,
//                     MaterialPageRoute(
//                       builder: (context) => LocationsPage(
//                         compositionID: compositionID,
//                         customFilePath01: customFilePath01,
//                         customFilePath02: customFilePath02,
//                         customFilePath03: customFilePath03,
//                         customFilePath04: customFilePath04,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),

    );
  }
}
