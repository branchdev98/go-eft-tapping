import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_eft_tapping/goeftbridge.dart';
import 'package:wakelock/wakelock.dart';
import 'package:path_provider/path_provider.dart';

//import 'package:assets_audio_player/assets_audio_player.dart';
import 'localization/keys/locale_keys.g.dart';

// ignore: must_be_immutable
class GoEFTTappingPage extends StatefulWidget {
  const GoEFTTappingPage({Key? key}) : super(key: key);

  @override
  State<GoEFTTappingPage> createState() => _GoEFTTappingState();
}

var arrPlayList = [];
var audiofilepos = 0;

var arrPlayListF = [
  3,
  0,
  -2,
  5,
  0,
  -2,
  7,
  0,
  -2,
  9,
  0,
  10,
  11,
  0,
  12,
  -2,
  13,
  0,
  14,
  -2,
  15,
  0,
  16,
  -2,
  17,
  -2,
  18
];

var arrPlayListE1 = [
  1,
  0,
  2,
  0,
  3,
  0,
  4,
  0,
  5,
  0,
  6,
  0,
  7,
  0,
  8,
  0,
  9,
  0,
  10,
  0,
  11,
  0,
  12,
  0,
  13,
  -1,
  14
];

var arrPlayListE2 = [
  15,
  0,
  16,
  0,
  17,
  0,
  18,
  0,
  19,
  0,
  20,
  0,
  21,
  0,
  22,
  -1,
  23
];
var mode;
enum track { E1, E2, F }
var mode_result = false;

class _GoEFTTappingState extends State<GoEFTTappingPage>
    with WidgetsBindingObserver {
  // String audioasset = 'assets/audio/' + LocaleKeys.lang.tr() + 'audioe1.mp3';
  AudioPlayer player = AudioPlayer();
  AudioCache audioCache = AudioCache();

  String audioasset = "";
  bool playCompleted = false;
  bool playPaused = false;

  Future loadplayer() async {
    audioasset = await getAssetFile(mode, audiofilepos);
    if (kIsWeb) {
      //Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      player.notificationService.startHeadlessService();
    }
    audioCache = AudioCache(prefix: 'assets/audio/');
    player = await audioCache.play(audioasset);
    //  await player.stop();
    await player.setVolume(0.5);
    playCompleted = false;

    player.onPlayerStateChanged.listen((PlayerState s) => {
          print('Current player state: $s'),
          Wakelock.toggle(enable: !playPaused && !playCompleted),
        });
    player.onPlayerCompletion.listen((event) async {
      audiofilepos++;
      print("audiofilepos = $audiofilepos");
      print("playcompleted = $playCompleted");
      if (audiofilepos == arrPlayList.length) {
        setState(() {
          playCompleted = true;
          playPaused = true;
          player.onPlayerCompletion.listen(null);
          audiofilepos = 0;
        });
      }

      if (playCompleted == true) return;

      audioasset = await getAssetFile(mode, audiofilepos);
      print("audioasset = $audioasset");
      if (arrPlayList[audiofilepos] >= 1) {
        //    ByteData bytes =
        //        await rootBundle.load(audioasset); //load audio from assets
        //   audiobytes =
        //       bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        //convert ByteData to Uint8List
        await player.setVolume(0.5);
        //player.playBytes(audiobytes);
        loadplayer();
        //  player = await audioCache.play(audioasset);
        //  player.resume();
      } else {
        //String playingFile;
        print("ready to play user");

        //  player.stop();
        if (File(audioasset).existsSync()) {
          print("user problem exist");
          await player.setVolume(1);
          player.play(audioasset, isLocal: true);
        }
      }
    });
    //convert ByteData to Uint8List
  }

  Future startPlaylist() async {
    //await player.release();

    await loadplayer();
    player.resume();
    //  player.playBytes(audiobytes);
  }

  String getAssetPath(var mode) {
    String audiopath = "";
    switch (mode) {
      case track.F:
        audiopath = LocaleKeys.lang.tr() + "audiof";

        break;
      case track.E1:
        audiopath = LocaleKeys.lang.tr() + "audioe";

        break;
      case track.E2:
        audiopath = LocaleKeys.lang.tr() + "audioe";

        break;
    }
    return audiopath;
  }

  Future<String> getAssetFile(var mode, var audiofilepos) async {
    print("arrplaylist");
    switch (mode) {
      case track.F:
        arrPlayList = arrPlayListF;
        break;
      case track.E1:
        arrPlayList = arrPlayListE1;
        break;
      case track.E2:
        arrPlayList = arrPlayListE2;
        break;
    }
    print("arrplaylist1");

    print(audiofilepos);
    print(arrPlayList[audiofilepos]);
    if (arrPlayList[audiofilepos] == -2) {
      audioasset = await getFilePath("preferred");
    } else if (arrPlayList[audiofilepos] == 0) {
      audioasset = await getFilePath("problem");
    } else if (arrPlayList[audiofilepos] == -1) {
      audioasset = await getFilePath("intensity");
    } else {
      audioasset =
          getAssetPath(mode) + arrPlayList[audiofilepos].toString() + ".mp3";
    }
    return audioasset;
  }

  whatismode(frombridge) {
    if (frombridge == true) {
      mode = track.F;
    } else {
      if (nextflow == false) {
        print("track e1:");
        mode = track.E1;
      } else {
        print("track e2:");
        mode = track.E2;
      }
    }
    print(mode);
  }

  void initState() {
    super.initState();
    print("initstate");
    WidgetsBinding.instance?.addObserver(this);

    whatismode(false);
    //".mp3";
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    //loadAssetsPlay();
    startPlaylist();
  }

  int i = 0;
  late String recordFilePath;
  Future<String> getFilePath(String what) async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    print("get file path passed");
    return sdPath + "/user" + what + ".mp3";
  }

  var disableBtn = false;

  bool nextflow = false;
  int filepos = 1;

  Widget getFooterSection() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: 20),
        InkWell(
            child: Image.asset(
              (LocaleKeys.lang.tr() == "ara")
                  ? "assets/images/btnarabridge.png"
                  : "assets/images/btnengbridge.png",
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width / 5,
              height: MediaQuery.of(context).size.width / 6,
            ),
            onTap: () async {
              player.stop();

              playCompleted = true;
              mode_result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoEFTBridge()),
              );

              whatismode(mode_result);
              setState(() {});
              audiofilepos = 0;
              loadplayer();
              // ByteData bytes =
              //     await rootBundle.load(audioasset); //load audio from assets
              // audiobytes = bytes.buffer
              //     .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
              playCompleted = false;

              //player.playBytes(audiobytes);
            }),
        SizedBox(width: MediaQuery.of(context).size.width / 3 * 2),
      ]),
      SizedBox(height: 10),
      Container(
          width: MediaQuery.of(context).size.width,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                  child: Stack(
                      alignment: Alignment.bottomLeft,
                      fit: StackFit.passthrough,
                      children: [
                        Ink.image(
                          image: const AssetImage("assets/images/btnhome.png"),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                        ),
                      ]),
                  onTap: () async {
                    if (kDebugMode) {
                      print("tapped home");
                    }
                    int result = await player.stop();

                    if (result == 1) {
                      //pause success
                      //nextflow = false;

                      setState(() {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);

                        audiofilepos = 0;
                      });
                    } else {
                      if (kDebugMode) {
                        print("Error on pause audio.");
                      }
                    }
                  }),
            ),
            const SizedBox(width: 10),
            Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                  child: (playPaused == true || playCompleted == true)
                      ? Image.asset(
                          "assets/images/btnplay.png",
                          fit: BoxFit.fitHeight,
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                        )
                      : Image.asset(
                          "assets/images/btnpause.png",
                          fit: BoxFit.fitHeight,
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 8,
                        ),
                  onTap: () async {
                    //disableBtn = true;

                    if (playCompleted) {
                      audiofilepos = 0;
                      setState(() {
                        playPaused = false;
                        playCompleted = false;
                      });
                      whatismode(mode_result);
                      loadplayer();
                    } else {
                      if (playPaused == false) {
                        player.pause();
                        setState(() {
                          playPaused = true;
                        });
                      } else if (playPaused == true) {
                        player.resume();
                        setState(() {
                          playPaused = false;
                        });
                      }
                    }
                  }),
            ),
            const SizedBox(width: 10),
            Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage("assets/images/btnstop.png"),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 8,
                child: InkWell(onTap: () async {
                  disableBtn = false;
                  int result = await player.stop();

                  setState(() {
                    if (result == 1) {
                      playCompleted = true;

                      audiofilepos = 0;
                    }
                  });
                  //  stopRecord();
                }),
              ),
            ),
            const SizedBox(width: 10),
            IgnorePointer(
                ignoring: mode == track.F,
                child: Container(
                  foregroundDecoration: mode == track.F
                      ? const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.lighten)
                      : null,
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Ink.image(
                      image: mode == track.E1
                          ? const AssetImage("assets/images/btnnext.png")
                          : const AssetImage("assets/images/btnrepeat.png"),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 8,
                      child: InkWell(onTap: () async {
                        int result = await player.stop();
                        if (result == 1) {
                          setState(() {
                            mode = track.E2;

                            audiofilepos = 0;
                          });
                          // audioasset = await getAssetFile(mode, audiofilepos);

                          //  ByteData bytes = await rootBundle
                          //      .load(audioasset); //load audio from assets
                          //  audiobytes = bytes.buffer.asUint8List(
                          //     bytes.offsetInBytes, bytes.lengthInBytes);

                          //convert ByteData to Uint8List
                          //  await player.setVolume(0.5);
                          // player = await audioCache.play(audioasset);
                          playCompleted = false;
                          loadplayer();
                          //  player
                          //     .playBytes(audiobytes)
                          //     .then((playCompleted) => false);
                        }
                        //  stopRecord();
                      }),
                    ),
                  ),
                )),
          ]))
    ]);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      //stop your audio player
      player.pause();
      setState(() {
        playPaused = true;
      });
    }
    if (state == AppLifecycleState.resumed) {
      // player.resume();
    }
  }

  @override
  Future<void> dispose() async {
    player.stop();
    playCompleted = true;
    nextflow = false;
    print("Back To old Screen");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
            body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(LocaleKeys.pageetitle,
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).size.width / 11),
                                color: Colors.black,
                              )).tr(),
                        ),
                      ),
                    ],
                  ),
                  Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(LocaleKeys.thesound,
                          style: TextStyle(
                            fontSize: (MediaQuery.of(context).size.width / 32),
                            color: Colors.black,
                          )).tr(),
                    ),
                  ),
                ],
                /* add child content here */
              ),
              Stack(
                alignment: (LocaleKeys.lang.tr() == "ara")
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),

                      //   alignment: Alignment.bottomRight,

                      Image.asset(
                        (LocaleKeys.lang.tr() == "ara")
                            ? "assets/images/aragirl.png"
                            : "assets/images/girl.png",
                        fit: BoxFit.cover,
                        width: math.min(MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width) /
                            1.4,
                        height: math.min(MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width) /
                            1.1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 30,
                    left: (LocaleKeys.lang.tr() == "ara")
                        ? MediaQuery.of(context).size.width -
                            math.min(MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.height) /
                                2.7
                        : 20,
                    child: Text(
                      LocaleKeys.acupoints2,
                      style: TextStyle(
                          height: (LocaleKeys.lang.tr() == "ara") ? 1.1 : 1.5,
                          fontSize: math.min(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height) /
                              (LocaleKeys.lang.tr() == "ara" ? 20 : 25),
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ).tr(),
                  ),
                  Positioned(
                    top: math.min(MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width) /
                            1.1 +
                        ((LocaleKeys.lang.tr() == "ara") ? 5 : 5),
                    left: (LocaleKeys.lang.tr() == "ara")
                        ? MediaQuery.of(context).size.width -
                            math.min(MediaQuery.of(context).size.height,
                                    MediaQuery.of(context).size.width) /
                                1.5 -
                            10
                        : math.min(MediaQuery.of(context).size.height,
                                    MediaQuery.of(context).size.width) /
                                1.5 -
                            20,
                    child: Text(
                      LocaleKeys.acupoints,
                      style: TextStyle(
                          height: 1.0,
                          fontSize: math.min(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height) /
                              26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ).tr(),
                  ),
                ],
              ),
              getFooterSection(),

              /* add child content here */
            ],
          ),
        )));
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
