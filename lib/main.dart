// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('sv', ''), // Spanish, no country code
      ],
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
  String maxpostlabel = "00:00";
  int maxduration = 40;

  String audioasset = "assets/audio/audiob.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    //return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

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
        int sseconds = Duration(milliseconds: maxduration).inSeconds;

        final total = Duration(seconds: sseconds);

        maxpostlabel = "${_printDuration(total)}";
        print("${_printDuration(total)}");
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

        final now = Duration(seconds: sseconds);

        currentpostlabel = "${_printDuration(now)}";

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
          Material(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: isplaying
                        ? AssetImage("assets/images/pausebutton.png")
                        : AssetImage("assets/images/infobutton.png"),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    child: InkWell(
                      onTap: () async {
                        if (!isplaying && !audioplayed) {
                          int result = await player.playBytes(audiobytes);
                          if (result == 1) {
                            //play success
                            setState(() {
                              isplaying = true;
                              audioplayed = true;
                            });
                          } else {
                            print("Error while playing audio.");
                          }
                        } else if (audioplayed && !isplaying) {
                          int result = await player.resume();
                          if (result == 1) {
                            //resume success
                            setState(() {
                              isplaying = true;
                              audioplayed = true;
                            });
                          } else {
                            print("Error on resume audio.");
                          }
                        } else {
                          int result = await player.pause();
                          if (result == 1) {
                            //pause success
                            setState(() {
                              isplaying = false;
                            });
                          } else {
                            print("Error on pause audio.");
                          }
                        }
                      },
                    ),
                  ),
                ]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
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
                      int result =
                          await player.seek(Duration(milliseconds: seekval));
                      if (result == 1) {
                        //seek successful
                        currentpos = seekval;
                      } else {
                        print("Seek unsuccessful.");
                      }
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(currentpostlabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        )),
                    SizedBox(width: 10), // use Spacer
                    Text(maxpostlabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        )),
                    SizedBox(width: 20),
                  ],
                )
              ],
            ),
          ),
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
          Stack(alignment: Alignment.bottomCenter, children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 85,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: new AssetImage("assets/images/background.png"),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 85,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: new AssetImage("assets/images/bottombg.png"),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 10,
              top: 10,
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(AppLocalizations.of(context)!.goefttapping,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                      )),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 8 * 7.2,
              top: 5,
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(AppLocalizations.of(context)!.copyright,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      )),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 8,
              top: 55,
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(AppLocalizations.of(context)!.thesound,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      )),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 0.7,
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
                      width: MediaQuery.of(context).size.width / 4 * 3,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!.eftintro,
                            style:
                                TextStyle(fontSize: 30, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 1.2,
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
                      width: MediaQuery.of(context).size.width / 4 * 3,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!.youreft,
                            style:
                                TextStyle(fontSize: 30, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 1.7,
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
                      width: MediaQuery.of(context).size.width / 4 * 3,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!.contactme,
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
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
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("ENGLISH",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2 +
                  MediaQuery.of(context).size.width / 4 * 0.98,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
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
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Swedish\nSVENSKA",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2 +
                  MediaQuery.of(context).size.width / 4 * 2,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
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
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: 50,
                      child: InkWell(onTap: () {}),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Arabic\n",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height - 130,
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
            Positioned(
              left: 50,
              top: MediaQuery.of(context).size.height - 130,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Ink.image(
                    image: AssetImage("assets/images/shareall.png"),
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    child: InkWell(onTap: () {}),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: MediaQuery.of(context).size.height - 120,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(AppLocalizations.of(context)!.sharingiscaring,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
