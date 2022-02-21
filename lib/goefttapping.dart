import 'dart:convert';

import 'dart:io';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/goeftbridge.dart';

import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

class _GoEFTTappingState extends State<GoEFTTappingPage>
    with WidgetsBindingObserver {
  late WebViewController _webViewController;

  // String audioasset = 'assets/audio/' + LocaleKeys.lang.tr() + 'audioe1.mp3';
  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;

  String audioasset = "";
  bool playCompleted = false;

  Future play() async {
    audioasset = await getAssetFile(mode, audiofilepos);
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //convert ByteData to Uint8List
    int result = await player.playBytes(audiobytes);
    if (result == 1) {
      audiofilepos++;

      setState(() {
        pause = false;
        playCompleted = false;
      });
    }
  }

  Future startPlaylist() async {
    play();
    //await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    //final result = await player.play(file.path, isLocal: true);
    //final result = await player.play(audioasset);
    //if (result == 1) setState(() => playerState = PlayerState.playing);
    player.onPlayerCompletion.listen((event) async {
      if (audiofilepos == arrPlayList.length) {
        setState(() {
          playCompleted = true;
          audiofilepos = 0;
          pause = true;
        });
      }

      if (playCompleted == true) return;

      audioasset = await getAssetFile(mode, audiofilepos);

      if (arrPlayList[audiofilepos] >= 1) {
        ByteData bytes =
            await rootBundle.load(audioasset); //load audio from assets
        audiobytes =
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        //convert ByteData to Uint8List
        int result = await player.playBytes(audiobytes);
        if (result == 1) {
          print(audioasset + " PLAYING NOW!!!");

          audiofilepos++;
        }
      } else {
        //String playingFile;
        print("ready to play user");

        if (File(audioasset).existsSync()) {
          print("user problem exist");
          int result = await player.play(audioasset, isLocal: true);
          if (result == 1) {
            print(audioasset + "  PLAYING NOW!!!");

            audiofilepos++;
          }
        }
      }
    });
  }

  String getAssetPath(var mode) {
    String audiopath = "";
    switch (mode) {
      case track.F:
        audiopath = "assets/audio/" + LocaleKeys.lang.tr() + "audiof";

        break;
      case track.E1:
        audiopath = "assets/audio/" + LocaleKeys.lang.tr() + "audioe";

        break;
      case track.E2:
        audiopath = "assets/audio/" + LocaleKeys.lang.tr() + "audioe";

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

  Future<void> whatismode(frombridge) async {
    // print("what is mode ");
    // String temp;
    //temp = await getFilePath("preferred");
    // print("audioasset = " + audioasset);
    //if (File(temp).existsSync()) {
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
    WidgetsBinding.instance.addObserver(this);
    pause = false;
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
  bool pause = false;
  bool nextflow = false;
  int filepos = 1;

  Widget getFooterSection() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        InkWell(
            child: Image.asset(
              (LocaleKeys.lang == "ara")
                  ? "assets/images/btnarabridge.png"
                  : "assets/images/btnengbridge.png",
              fit: BoxFit.fitHeight,
              width: MediaQuery.of(context).size.width / 5,
              height: MediaQuery.of(context).size.height / 10,
            ),
            onTap: () async {
              int result = await player.stop();

              if (result == 1) {
                //pause success
                //nextflow = false;
                // audioasset = await getFilePath("preferred");
                //  if (File(audioasset).existsSync()) {
                //    File(audioasset).deleteSync();
                //  }
                //  Navigator.pop(context);
                var result = false;
                result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoEFTBridge()),
                ); /*.then((_) {
                 
                });
               */
                whatismode(result);
                pause = false;
                audiofilepos = 0;
                setState(() {});
                play();

                setState(() {
                  audiofilepos = 0;
                });
              }
            }),
        SizedBox(width: MediaQuery.of(context).size.width / 3 * 2),
      ]),
      SizedBox(height: 10),
      Container(
          width: MediaQuery.of(context).size.width,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                  child: pause
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
                    int result = 0;

                    if (pause == false) {
                      result = await player.pause();
                    } else {
                      if (playCompleted) {
                        audiofilepos = 0;
                        play();
                      } else {
                        result = await player.resume();
                      }
                    }

                    setState(() {
                      if (result == 1) pause = !pause;
                    });
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
                      pause = true;
                      audiofilepos = 0;
                    }
                  });
                  //  stopRecord();
                }),
              ),
            ),
            const SizedBox(width: 10),
            IgnorePointer(
                ignoring: mode == track.E2 || mode == track.F,
                child: Container(
                  foregroundDecoration: mode == track.E2 || mode == track.F
                      ? const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.lighten)
                      : null,
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Ink.image(
                      image: const AssetImage("assets/images/btnnext.png"),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 8,
                      child: InkWell(onTap: () async {
                        int result = await player.stop();
                        if (result == 1) {
                          setState(() {
                            mode = track.E2;
                            playCompleted = false;
                            audiofilepos = 0;
                            pause = false;
                          });
                          play();
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
  Future<void> dispose() async {
    int result = await player.stop();
    if (result == 1) {
      setState(() {
        //    initState();
        pause = true;
      });
    } else {}
    print("Back To old Screen");
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      //stop your audio player
      int result = await player.pause();
      if (result == 1) {
        setState(() {
          // initState();
          pause = true;
        });
      } else {
        int result = await player.resume();
        if (result == 1) {
          setState(() {
            // initState();
            pause = false;
          });
        }
        print(state.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 0,

            child: Image.asset(
                "assets/images/" + LocaleKeys.lang.tr() + "acubg.png",
                fit: BoxFit.fill),
            //  fit: BoxFit.fill,
          ),
          Positioned(
            left: 0,
            top: (MediaQuery.of(context).size.height - 136),
            child: getFooterSection(),
          ),
        ]),
        /*,*/
      ),
    );
  }

  loadAsset() async {
    // play();
    String fileHtmlContents = await rootBundle
        .loadString('assets/html/' + LocaleKeys.lang.tr() + 'intro.html');
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
