import 'dart:io';

import 'dart:typed_data';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';

import 'localization/keys/locale_keys.g.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

enum RecordState { none, before, recording, recorded }

String statusText = "";
late String recordFilePath;
var playerState;

class GoEFTBridge extends StatefulWidget {
  const GoEFTBridge({Key? key}) : super(key: key);

  @override
  State<GoEFTBridge> createState() => _GoEFTBridgeState();
}

var state = RecordState.before;

class _GoEFTBridgeState extends State<GoEFTBridge> with WidgetsBindingObserver {
  // ignore: non_constant_identifier_names

  AudioPlayer player = AudioPlayer();
  AudioCache audioCache = AudioCache();
  late Uint8List audiobytes;
  var audiofilepos = 0;
  var checkeddisclaimer = false;
  var disableBtn = false;
  var audioasset = "";

  var playCompleted = false;
  var userrecorded = false;

  var playPaused = false;
  var arrPlayList = [1, 0, 2];

  Future<String> getAssetFile(var audiofilepos) async {
    print("arrplaylist1");

    print(arrPlayList[audiofilepos]);
    if (arrPlayList[audiofilepos] == -2) {
      audioasset = await getFilePath("preferred");
    } else if (arrPlayList[audiofilepos] == 0) {
      audioasset = await getFilePath("problem");
    } else if (arrPlayList[audiofilepos] == -1) {
      audioasset = await getFilePath("intensity");
    } else {
      audioasset = LocaleKeys.lang.tr() +
          "audiof" +
          arrPlayList[audiofilepos].toString() +
          ".mp3";
    }
    return audioasset;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      //stop your audio player
      player.pause();
      setState(() {
        playPaused = true;
      });
    }
    if (state == AppLifecycleState.resumed) {
      //  player.resume();
    }
  }

  @override
  Future<void> dispose() async {
    player.stop();

    print("Back To old Screen");
    super.dispose();
  }

  Future<void> loadplayer() async {
    audioasset = await getAssetFile(audiofilepos);
    if (kIsWeb) {
      //Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      player.notificationService.startHeadlessService();
    }
    audioCache = AudioCache(prefix: 'assets/audio/');
    player = await audioCache.play(audioasset);
    // ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    //  audiobytes =
    //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //playCompleted = false;
    // playPaused = false;
    player.onPlayerStateChanged.listen((PlayerState s) => {
          print('Current player state: $s'),
          Wakelock.toggle(enable: !playPaused && !playCompleted),
          // setState(() => playerState = s)
        });
    player.onPlayerCompletion.listen((event) async {
      audiofilepos++;
      print("audiofilepos = $audiofilepos");
      print("playcompleted = $playCompleted");
      if (audiofilepos == arrPlayList.length) {
        setState(() {
          playCompleted = true;
          playPaused = false;
          player.onPlayerCompletion.listen(null);
          audiofilepos = 0;
        });
      }

      if (playCompleted == true) return;

      audioasset = await getAssetFile(audiofilepos);
      print("audioasset = $audioasset");
      if (arrPlayList[audiofilepos] >= 1) {
        loadplayer();
      } else {
        print("ready to play user");

        if (File(audioasset).existsSync()) {
          print("user problem exist");
          player.play(audioasset, isLocal: true);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    disableBtn = false; //no disable btn
    userrecorded = false; //
    state = RecordState.before;

    loadplayer();
  }

  Widget getFooterSection() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                    width: MediaQuery.of(context).size.width / 10,
                    height: MediaQuery.of(context).size.width / 10,
                  ),
                ]),
            onTap: () async {
              int result = await player.stop();
              if (result == 1) {
                //pause success
                Navigator.of(context).popUntil((route) => route.isFirst);
                setState(() {
                  // isplaying = false;
                });
              } else {
                if (kDebugMode) {
                  print("Error on pause audio.");
                }
              }
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
                        fontSize: MediaQuery.of(context).size.width /
                            ((LocaleKeys.lang.tr() == "ara") ? 15 : 30),
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
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
              Ink.image(
                image: (state == RecordState.recording)
                    ? const AssetImage("assets/images/btnstop.png")
                    : !playPaused && !playCompleted
                        ? const AssetImage("assets/images/btnpause.png")
                        : const AssetImage("assets/images/btnplay.png"),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width / 10,
                height: MediaQuery.of(context).size.width / 10,
                child: InkWell(onTap: () async {
                  if (state == RecordState.recording) {
                    stopRecord();
                  } else if (state == RecordState.before) {
                    if (!playPaused && !playCompleted) {
                      player.pause();
                      setState(() {
                        playPaused = true;
                      });
                    } else if (playPaused) {
                      player.resume();
                      setState(() {
                        playPaused = false;
                        playCompleted = false;
                      });
                    } else {
                      audiofilepos = 0;
                      loadplayer();
                      setState(() {
                        playPaused = false;
                        playCompleted = false;
                      });
                    }
                  }
                }),
              ),
            ]),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      // left: true,
      bottom: true,
      child: Scaffold(
          //key: YourEFT,
          body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
            //alignment: Alignment.topCenter,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            //    mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Material(
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(LocaleKeys.copyright,
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).size.width / 25),
                                color: Colors.black,
                              )).tr(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.whenihavethis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ).tr(),
                  ),
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
                  Expanded(
                    child: Text(
                      LocaleKeys.ichoosetofeel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ).tr(),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                "assets/images/bridge.png",
              ),
              SizedBox(
                height: 100,
              ),
              getFooterSection(),
              SizedBox(
                height: 2,
              )
            ]),
      )),
    );
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
    if (File(recordFilePath).existsSync()) {
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
  }

  void stopRecord() async {
    bool s = await RecordMp3.instance.stop();
    if (s) {
      statusText = "录音已完成";

      setState(() {
        state = RecordState.before;
      });
      Navigator.pop(context, true);
    }
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
