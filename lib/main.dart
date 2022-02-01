// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GO EFT Tapping'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentpos = 0;
  String currentpostlabel = "00:00";
  int maxduration = 100;

  String audioasset = "assets/audio/red-indian-music.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List

      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rhours:$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });
    super.initState();
  }

  Widget getTitleSection() {
    return Container(
      padding: const EdgeInsets.all(1),
      color: Colors.black,
      child: Row(
        children: [
          Icon(
            Icons.help,
            color: Colors.blue[500],
            size: 50,
          ),
          Expanded(
              child: Slider(
            value: double.parse(currentpos.toString()),
            activeColor: Colors.blue[200],
            inactiveColor: Colors.white,
            min: 0,
            max: double.parse(maxduration.toString()),
            divisions: maxduration,
            label: currentpostlabel,
            onChanged: (double value) async {
              int seekval = value.round();
              int result = await player.seek(Duration(milliseconds: seekval));
              if (result == 1) {
                //seek successful
                currentpos = seekval;
              } else {
                print("Seek unsuccessful.");
              }
            },
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void _yourFunction(String searchqueries) {}
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: ListView(
        children: [
          getTitleSection(),
          Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/eng_bg.png', fit: BoxFit.cover),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 140,
              top: MediaQuery.of(context).size.height / 4 * 0.6,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: AssetImage("assets/images/bluebutton.png"),
                      fit: BoxFit.cover,
                      width: 280,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("EFT INTRO",
                            style:
                                TextStyle(fontSize: 40, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 140,
              top: MediaQuery.of(context).size.height / 4 * 1.05,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: AssetImage("assets/images/greenbutton.png"),
                      fit: BoxFit.cover,
                      width: 280,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("YOUR EFT",
                            style:
                                TextStyle(fontSize: 40, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 140,
              top: MediaQuery.of(context).size.height / 4 * 1.5,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image:
                          AssetImage("assets/images/orangecontactbutton.png"),
                      fit: BoxFit.cover,
                      width: 280,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("CONTACT ME",
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 140,
              top: MediaQuery.of(context).size.height / 4 * 2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: AssetImage("assets/images/bluebutton.png"),
                      fit: BoxFit.cover,
                      width: 90,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("English",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 46,
              top: MediaQuery.of(context).size.height / 4 * 2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: AssetImage("assets/images/greenbutton.png"),
                      fit: BoxFit.cover,
                      width: 90,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Swedish",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + 50,
              top: MediaQuery.of(context).size.height / 4 * 2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image:
                          AssetImage("assets/images/orangecontactbutton.png"),
                      fit: BoxFit.cover,
                      width: 90,
                      height: 70,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Arabic",
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 45,
              top: MediaQuery.of(context).size.height / 3 * 2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Ink.image(
                    image: AssetImage("assets/images/fbshare.png"),
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    child: InkWell(onTap: () {}),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
