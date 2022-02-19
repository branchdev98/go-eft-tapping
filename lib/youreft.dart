import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/goefttapping.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization/keys/locale_keys.g.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

enum record_state { none, before, recording, recorded }

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

class YourEFT extends StatefulWidget {
  const YourEFT({Key? key}) : super(key: key);

  @override
  State<YourEFT> createState() => _YourEFTState();
}

class _YourEFTState extends State<YourEFT> {
  //const YourEFTPage({Key? key}) : super(key: key);
  String checkedImagePath = "assets/images/unchecked.png";

  var problemState = record_state.none;
  // ignore: non_constant_identifier_names
  var intensityState = record_state.none;

  late WebViewController _webViewController;

  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;

  var checkeddisclaimer = false;
  var disableBtn = false;
  @override
  void initState() {
    super.initState();
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    isDisclaimercheck().then((checkeddisclaimer) => true);
  }

  Widget getFooterSection() {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IgnorePointer(
            ignoring: disableBtn,
            child: Container(
              foregroundDecoration: disableBtn
                  ? const BoxDecoration(
                      color: Colors.grey,
                      backgroundBlendMode: BlendMode.lighten)
                  : null,
              child: Material(
                //  elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: InkWell(
                    child: Stack(
                        alignment: Alignment.bottomLeft,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image:
                                const AssetImage("assets/images/btnhome.png"),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width / 10,
                            height: MediaQuery.of(context).size.width / 10,
                          ),
                        ]),
                    onTap: () async {
                      Navigator.pop(context);
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
                    }),
              ),
            ),
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
                        visible: (problemState == record_state.before) ||
                            (intensityState == record_state.before),
                        child: Image.asset(
                          "assets/images/btnred.png",
                          fit: BoxFit.fitHeight,
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.width / 9,
                        ),
                      ),
                      Text(
                        (problemState == record_state.before)
                            ? LocaleKeys.recordproblem
                            : (intensityState == record_state.before)
                                ? LocaleKeys.recordintensity
                                : (problemState == record_state.recording)
                                    ? LocaleKeys.recordingproblem
                                    : (intensityState == record_state.recording)
                                        ? LocaleKeys.recordingintensity
                                        : "",
                        style: TextStyle(
                            fontSize: (LocaleKeys.lang.tr() == "ara")
                                ? MediaQuery.of(context).size.width / 20
                                : MediaQuery.of(context).size.width / 30,
                            fontWeight: (LocaleKeys.lang.tr() == "ara")
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: (problemState == record_state.recording ||
                                    intensityState == record_state.recording)
                                ? Colors.red
                                : Colors.white),
                      ).tr(),
                    ]),
                onTap: () async {
                  if (problemState == record_state.before) {
                    startRecord("problem");
                    //   problemState = record_state.recording;
                  }
                  if (intensityState == record_state.before) {
                    startRecord("intensity");
                    //   intensityState = record_state.recording;
                  }
                  disableBtn = true;
                  setState(() {});
                }),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: (problemState == record_state.recording) ||
                (intensityState == record_state.recording),
            child: Material(
              //  elevation: 8.0,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: const AssetImage("assets/images/btnstop.png"),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 10,
                      height: MediaQuery.of(context).size.width / 10,
                      child: InkWell(onTap: () {
                        disableBtn = false;
                        if (problemState == record_state.recording) {
                          problemState = record_state.recorded;
                        }
                        if (intensityState == record_state.recording) {
                          intensityState = record_state.recorded;
                        }

                        //    AppLocalization.load(Locale('en', ''));
                        //  context.read<LocaleProvider>().setLocale(localeEN);
                        setState(() {});
                        stopRecord();
                      }),
                    ),
                  ]),
            ),
          ),
        ]));
  }

  Future<bool> isDisclaimercheck() async {
    final prefs = await SharedPreferences.getInstance();

    var disclaimerchecked = prefs.getBool('disclaimercheck');
    if (disclaimerchecked != null && !disclaimerchecked) {
      return false;
    } else {
      setState(() {
        checkeddisclaimer = true;
      });
      return true;
    }
  }

  Future<bool> setDisclaimercheck() async {
    final prefs = await SharedPreferences.getInstance();
    play("d1");
    prefs.setBool('disclaimercheck', true);
    return true;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //key: YourEFT,
        body: ListView(children: [
      Stack(
        alignment: Alignment.bottomCenter,
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
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                (MediaQuery.of(context).size.width / 10) * 3.6,
            top: 30,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(LocaleKeys.goefttapping,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width / 10),
                      color: Colors.black,
                    )).tr(),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 +
                (MediaQuery.of(context).size.width / 10) * 3.6,
            top: 25,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(LocaleKeys.copyright,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width / 15),
                      color: Colors.black,
                    )).tr(),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                (MediaQuery.of(context).size.width / 10) * 3.6,
            top: (MediaQuery.of(context).size.width / 10) + 40,
            child: Material(
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
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                (MediaQuery.of(context).size.width / 10) * 4.0,
            top: (MediaQuery.of(context).size.width / 10) + 54,
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(LocaleKeys.yourrecording,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width / 32),
                      color: Colors.black,
                    )).tr(),
              ),
            ),
          ),

          //Disclaimer Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 0.9,
            child: Material(
              elevation: 4.0,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: IgnorePointer(
                ignoring: disableBtn || checkeddisclaimer,
                child: Container(
                  foregroundDecoration: disableBtn
                      ? const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.lighten)
                      : null,
                  child: InkWell(
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.passthrough,
                      children: [
                        Ink.image(
                          image: const AssetImage("assets/images/btnwhite.png"),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width / 4 * 3,
                          height: MediaQuery.of(context).size.width / 6,
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Material(
                                  //elevation: 0,
                                  clipBehavior: Clip.hardEdge,
                                  color: Colors.transparent,
                                  child: Image.asset(
                                    checkeddisclaimer
                                        ? "assets/images/checked.png"
                                        : "assets/images/unchecked.png",
                                    fit: BoxFit.fitWidth,
                                    width:
                                        MediaQuery.of(context).size.width / 20,
                                    height:
                                        MediaQuery.of(context).size.width / 20,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width / 10),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              LocaleKeys.ihaveheard,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  color: Colors.black),
                            ).tr(),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (checkeddisclaimer) return;
                      checkeddisclaimer = true;
                      checkedImagePath = "assets/images/checked.png";
                      setDisclaimercheck();

                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),

          //feeling button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 1.4,
            child: IgnorePointer(
              ignoring: disableBtn,
              child: Container(
                foregroundDecoration: disableBtn
                    ? const BoxDecoration(
                        color: Colors.grey,
                        backgroundBlendMode: BlendMode.lighten)
                    : null,
                child: Material(
                  elevation: 4.0,
                  clipBehavior: Clip.hardEdge,
                  color: Colors.transparent,
                  child: InkWell(
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image: const AssetImage("assets/images/btnred.png"),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width / 4 * 3,
                            height: MediaQuery.of(context).size.width / 6,
                          ),
                          Text(
                                  problemState == record_state.recorded
                                      ? LocaleKeys.myfeelingrecorded
                                      : LocaleKeys.myfeeling,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                      color: Colors.white))
                              .tr(),
                        ],
                      ),
                      onTap: () {
                        if (intensityState != record_state.recorded) {
                          intensityState = record_state.none;
                        }
                        problemState = record_state.before;
                        play("d2");
                        setState(() {});
                      }),
                ),
              ),
            ),
          ),
          //intensity button.
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 1.9,
            child: IgnorePointer(
              ignoring: disableBtn,
              child: Container(
                foregroundDecoration: disableBtn
                    ? const BoxDecoration(
                        color: Colors.grey,
                        backgroundBlendMode: BlendMode.lighten)
                    : null,
                child: Material(
                  elevation: 4.0,
                  clipBehavior: Clip.hardEdge,
                  color: Colors.transparent,
                  child: InkWell(
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image:
                                const AssetImage("assets/images/btnblue.png"),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width / 4 * 3,
                            height: MediaQuery.of(context).size.width / 6,
                          ),
                          Text(
                                  intensityState == record_state.recorded
                                      ? LocaleKeys.theintensityrecorded
                                      : LocaleKeys.theintensity,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                      color: Colors.white))
                              .tr(),
                        ],
                      ),
                      onTap: () {
                        if (problemState == record_state.recording ||
                            intensityState == record_state.recording) return;
                        if (problemState != record_state.recorded) {
                          problemState = record_state.none;
                        }
                        intensityState = record_state.before;
                        play("d3");
                        setState(() {});
                      }),
                ),
              ),
            ),
          ),

          //    Positioned(child: child)
          //go eft tapping button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 2.5,
            child: IgnorePointer(
              ignoring: disableBtn,
              child: Container(
                foregroundDecoration: disableBtn
                    ? const BoxDecoration(
                        color: Colors.grey,
                        backgroundBlendMode: BlendMode.lighten)
                    : null,
                child: Material(
                  elevation: 4.0,
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  child: InkWell(
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image:
                                const AssetImage("assets/images/btngreen.png"),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width / 4 * 3,
                            height: MediaQuery.of(context).size.width / 6,
                          ),
                          Text(LocaleKeys.goefttapping,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                      color: Colors.white))
                              .tr(),
                        ],
                      ),
                      onTap: () {
                        print("checked:");
                        print(checkeddisclaimer);
                        if (problemState == record_state.recording ||
                            intensityState == record_state.recording) return;

                        if (checkeddisclaimer) {
                          if (problemState == record_state.recorded) {
                            if (intensityState == record_state.recorded) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GoEFTTappingPage()),
                              );
                              return;
                            }
                          }
                        }
                        if (problemState != record_state.recorded) {
                          problemState = record_state.none;
                        }
                        if (intensityState != record_state.recorded) {
                          intensityState = record_state.none;
                        }
                        play("d4");
                        //playRecorded("problem");
                      }),
                ),
              ),
            ),
          ),

          getFooterSection(),
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
        if (what == "problem") problemState = record_state.recording;
        if (what == "intensity") intensityState = record_state.recording;
      });
    }

    /* void resumeRecord() {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "正在录音中...";
        setState(() {});
      }
    }*/

    //late String recordFilePath;

    State<StatefulWidget> createState() => throw UnimplementedError();
  }
}

void stopRecord() {
  bool s = RecordMp3.instance.stop();
  if (s) {
    statusText = "录音已完成";
    isComplete = true;
    //   setState(() {});
  }
}
