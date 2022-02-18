import 'dart:convert';

import 'dart:io';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'localization/keys/locale_keys.g.dart';

// ignore: must_be_immutable
class GoEFTTappingFPage extends StatefulWidget {
  const GoEFTTappingFPage({Key? key}) : super(key: key);

  @override
  State<GoEFTTappingFPage> createState() => _GoEFTTappingFState();
}

int audiofilepos = 0;

var arrPlayList = [
  3,
  0,
  1,
  5,
  0,
  1,
  7,
  0,
  1,
  9,
  0,
  10,
  11,
  0,
  12,
  1,
  13,
  0,
  14,
  1,
  15,
  0,
  16,
  1,
  17,
  1,
  18
];

class _GoEFTTappingFState extends State<GoEFTTappingFPage> {
  late WebViewController _webViewController;

  // String audioasset = 'assets/audio/' + LocaleKeys.lang.tr() + 'audioe1.mp3';
  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;

  String audioasset = "";
  bool playCompleted = false;
  Future play() async {
    audioasset = "assets/audio/" +
        LocaleKeys.lang.tr() +
        "audiof" +
        arrPlayList[audiofilepos].toString() +
        ".mp3";

    print(audioasset);
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //convert ByteData to Uint8List
    int result = await player.playBytes(audiobytes);
    if (result == 1) audiofilepos++;
    //await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    //final result = await player.play(file.path, isLocal: true);
    //final result = await player.play(audioasset);
    //if (result == 1) setState(() => playerState = PlayerState.playing);
    player.onPlayerCompletion.listen((event) async {
      if (audiofilepos == arrPlayList.length) {
        setState(() {
          playCompleted = true;
          audiofilepos = 1;
          pause = true;
        });
      }

      if (playCompleted == true) return;
      if (arrPlayList[audiofilepos] > 2) {
        audioasset = "assets/audio/" +
            LocaleKeys.lang.tr() +
            "audiof" +
            arrPlayList[audiofilepos].toString() +
            ".mp3";

        ByteData bytes =
            await rootBundle.load(audioasset); //load audio from assets
        audiobytes =
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
        //convert ByteData to Uint8List
        int result = await player.playBytes(audiobytes);
        if (result == 1) {
          print("original sound F" +
              arrPlayList[audiofilepos].toString() +
              " is playing");
        }
      } else {
        if (arrPlayList[audiofilepos] == 1) {
          audioasset = await getFilePath("preferred");
        } else {
          audioasset = await getFilePath("problem");
        }
        //String playingFile;
        if (File(audioasset).existsSync()) {
          int result = await player.play(audioasset);
          if (result == 1) {
            print("user sound is playing");
          }
        }
      }
      audiofilepos++;
    });
  }

  void initState() {
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    //loadAssetsPlay();
    play();
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
    return sdPath + "/user" + what + ".mp3";
  }

  void playRecorded(String what) async {
    recordFilePath = await getFilePath(what);
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      //   AudioPlayer audioPlayer = AudioPlayer();
      player.play(recordFilePath, isLocal: true);
    }
  }

  var disableBtn = false;
  bool pause = false;
  bool nextflow = true;
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
                Navigator.pop(context);

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
                      result = await player.resume();
                    }

                    setState(() {
                      if (result == 1) pause = !pause;
                    });
                  }),
            ),
            const SizedBox(width: 10),
            Material(
              elevation: 8.0,
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
                ignoring: nextflow,
                child: Container(
                  foregroundDecoration: nextflow
                      ? const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.lighten)
                      : null,
                  child: Material(
                    elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Ink.image(
                      image: const AssetImage("assets/images/btnnext.png"),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 8,
                      child: InkWell(onTap: () async {
                        setState(() {});
                        //  stopRecord();
                      }),
                    ),
                  ),
                )),
          ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height - 0,
              child: FittedBox(
                child: Image.asset(
                    "assets/images/" + LocaleKeys.lang.tr() + "acubg.png"),
                fit: BoxFit.fill,
              )),
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
