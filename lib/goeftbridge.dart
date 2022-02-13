import 'dart:io';

import 'dart:typed_data';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/goefttappingf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/keys/locale_keys.g.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

enum RecordState { none, before, recording, recorded }

bool isComplete = false;
String statusText = "";
late String recordFilePath;

/*void pauseRecord() {
      if (RecordMp3.instance.status == RecordStatus.PAUSE) {
        bool s = RecordMp3.instance.resume();
        if (s) {
          statusText = "正在录音中...";
          setState(() {});
        }
      } else {
        bool s = RecordMp3.instance.pause();
        if (s) {
          statusText = "录音暂停中...";
          setState(() {});
        }
      }
    }
*/

class GoEFTBridge extends StatefulWidget {
  const GoEFTBridge({Key? key}) : super(key: key);

  @override
  State<GoEFTBridge> createState() => _GoEFTBridgeState();
}

var state = RecordState.before;

class _GoEFTBridgeState extends State<GoEFTBridge> {
  //const YourEFTPage({Key? key}) : super(key: key);
  String checkedImagePath = "assets/images/unchecked.png";

  // ignore: non_constant_identifier_names

  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;
  var audiofilepos = 1;
  var checkeddisclaimer = false;
  var disableBtn = false;
  var audioasset = "";
  var pause = false;
  var playCompleted = false;
  var userrecorded = false;
  Future play() async {
    userrecorded = false;
    audioasset = "assets/audio/" +
        LocaleKeys.lang.tr() +
        "audiof" +
        audiofilepos.toString() +
        ".mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //convert ByteData to Uint8List
    await player.playBytes(audiobytes);
    //await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    //final result = await player.play(file.path, isLocal: true);
    //final result = await player.play(audioasset);
    //if (result == 1) setState(() => playerState = PlayerState.playing);
    player.onPlayerCompletion.listen((event) async {
      if (audiofilepos == 2 && userrecorded == false) {
        setState(() {
          playCompleted = true;

          audiofilepos = 1;
          pause = true;
        });
      }
      if (playCompleted == true) return;
      if (userrecorded == true) {
        audioasset = "assets/audio/" +
            LocaleKeys.lang.tr() +
            "audiof" +
            audiofilepos.toString() +
            ".mp3";

        ByteData bytes =
            await rootBundle.load(audioasset); //load audio from assets
        audiobytes =
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        //convert ByteData to Uint8List
        int result = await player.playBytes(audiobytes);
        if (result == 1) {
          userrecorded = false;
          print("original sound" + audiofilepos.toString() + " is playing");
        }
      } else {
        if (audiofilepos == 1) {
          audioasset = await getFilePath("intensity");
        } else {
          audioasset = await getFilePath("problem");
        }
      }

      //String playingFile;
      if (File(audioasset).existsSync()) {
        int result = await player.play(audioasset);
        if (result == 1) {
          userrecorded = true;
          print("user sound is playing");
          audiofilepos++;
        }
      }
    });
  }

  void initState() {
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    //loadAssetsPlay();

    audiofilepos = 1;
    disableBtn = false;
    pause = false;
    playCompleted = false;
    userrecorded = false;

    play();
  }

  Widget getFooterSection() {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Material(
            elevation: 5.0,
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
                        width: MediaQuery.of(context).size.width / 10,
                        height: MediaQuery.of(context).size.width / 10,
                      ),
                    ]),
                onTap: () async {
                  int result = await player.stop();
                  if (result == 1) {
                    //pause success
                    setState(() {
                      // isplaying = false;
                    });
                  } else {
                    if (kDebugMode) {
                      print("Error on pause audio.");
                    }
                  }
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
          Material(
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: InkWell(
                child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: (state == RecordState.before ||
                            state == RecordState.recorded),
                        child: Image.asset(
                          "assets/images/btnred.png",
                          fit: BoxFit.fitHeight,
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.width / 9,
                        ),
                      ),
                      Text(
                        (state == RecordState.before ||
                                state == RecordState.recorded)
                            ? LocaleKeys.recordprefferedemotion
                            : (state == RecordState.recording)
                                ? LocaleKeys.recording
                                : "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 25,
                            color: (state == RecordState.recording)
                                ? Colors.red
                                : Colors.white),
                      ).tr(),
                    ]),
                onTap: () async {
                  if (state == RecordState.before ||
                      state == RecordState.recorded) {
                    startRecord("preferred");
                    //   problemState = RecordState.recording;
                  }

                  disableBtn = true;
                  setState(() {});
                }),
          ),
          Material(
            elevation: 8.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: (state == RecordState.recording)
                        ? const AssetImage("assets/images/btnstop.png")
                        : pause
                            ? const AssetImage("assets/images/btnplay.png")
                            : const AssetImage("assets/images/btnpause.png"),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 10,
                    height: MediaQuery.of(context).size.width / 10,
                    child: InkWell(onTap: () async {
                      if (state == RecordState.recording) {
                        stopRecord();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GoEFTTappingFPage()),
                        ).then((_) {
                          setState(() {
                            pause = false;
                          });

                          initState();
                        });
                      }
                      int result = 0;
                      if (pause == false) {
                        result = await player.pause();
                      } else {
                        result = await player.resume();
                      }

                      setState(() {
                        if (result == 1) pause = !pause;
                      });
                      //  disableBtn = false;
                      //   if (state == RecordState.recording) {
                      //    state = RecordState.recorded;
                      //  }

                      //    AppLocalization.load(Locale('en', ''));
                      //  context.read<LocaleProvider>().setLocale(localeEN);
                      //   setState(() {});
                      //   stopRecord();
                    }),
                  ),
                ]),
          )
        ]));
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();

    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      prefs.setBool('first_time', false);
      return false;
    } else {
      prefs.setBool('first_time', false);
      return true;
    }
  }

/*
  Future play(String what) async {
    // final file = new File(audioasset);

    String audioasset =
        'assets/audio/' + LocaleKeys.lang.tr() + 'audio' + what + '.mp3';

    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //convert ByteData to Uint8List
    if (kDebugMode) {
      print(audioasset);
    }
    await player.playBytes(audiobytes);
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //key: YourEFT,
        body: ListView(children: [
      Stack(
        alignment: Alignment.topCenter,
        children: [
          //background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 20,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/images/background.png"),
              ),
            ),
          ),
          //Title
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 30,
              ),
              Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(LocaleKeys.goeftbridgec,
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width / 10),
                        color: Colors.black,
                      )).tr(),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    LocaleKeys.whenihavethis,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 30,
                        color: Colors.black),
                  ).tr(),
                  const SizedBox(width: 30),
                  Material(
                    //elevation: 0,
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(
                          (LocaleKeys.lang.tr() == "ara") ? math.pi : 0),
                      child: Image.asset(
                        "assets/images/arrow.png",
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    LocaleKeys.ichoosetofeel,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 30,
                        color: Colors.black),
                  ).tr(),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Image.asset("assets/images/bridge.png"),
              SizedBox(height: 100),
              getFooterSection(),
            ],
          ),

          //Disclaimer Button

          //feeling button

          //    Positioned(child: child)
          //go eft tapping button
        ],
      ),
    ]));
  }

  Future<bool> checkPermission() async {
    await Permission.microphone.request();

    return Permission.microphone.isGranted;
  }

  int i = 0;

  Future<String> getFilePath(String what) async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/user" + what + ".mp3";
  }

  void playRecorded(String what) async {
    recordFilePath = await getFilePath(what);
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      //   AudioPlayer audioPlayer = AudioPlayer();
      player.play(recordFilePath, isLocal: true);
    }
  }

  void startRecord(String what) async {
    await player.stop();
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "正在录音中...";
      print(statusText);
      recordFilePath = await getFilePath(what);
      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "录音失败--->$type";
        setState(() {});
      });
      //   } else {
      //    statusText = "没有录音权限";
      //  }
      setState(() {
        state = RecordState.recording;
      });
    }

    /* void resumeRecord() {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "正在录音中...";
        setState(() {});
      }
    }*/

    @override
    // ignore: must_call_super
    void initState() {
      /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    }

    //late String recordFilePath;

    State<StatefulWidget> createState() => throw UnimplementedError();
  }
}

void stopRecord() {
  bool s = RecordMp3.instance.stop();
  if (s) {
    statusText = "录音已完成";
    state = RecordState.recorded;
    isComplete = true;
    //   setState(() {});
  }
}
