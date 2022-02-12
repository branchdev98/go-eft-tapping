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
import 'package:assets_audio_player/assets_audio_player.dart';
import 'localization/keys/locale_keys.g.dart';

// ignore: must_be_immutable
class GoEFTTappingPage extends StatefulWidget {
  const GoEFTTappingPage({Key? key}) : super(key: key);

  @override
  State<GoEFTTappingPage> createState() => _GoEFTTappingState();
}

class _GoEFTTappingState extends State<GoEFTTappingPage> {
  late WebViewController _webViewController;

  String audioasset = 'assets/audio/' + LocaleKeys.lang.tr() + 'audioe1.mp3';
  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;
  late AssetsAudioPlayer _assetsAudioPlayer;

  Future play() async {
    // final file = new File(audioasset);
    ByteData bytes = await rootBundle.load(audioasset); //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //convert ByteData to Uint8List
    await player.playBytes(audiobytes);
    //await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    //final result = await player.play(file.path, isLocal: true);
    //final result = await player.play(audioasset);
    //if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  void initState() {
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    loadAssetsPlay();
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
  bool nextflow = false;
  int filepos = 1;
  bool userrecord = true;

  Widget getFooterSection() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Image.asset(
          "assets/images/btnengbridge.png",
          fit: BoxFit.fitHeight,
          width: MediaQuery.of(context).size.width / 3,
          height: MediaQuery.of(context).size.height / 8,
        ),
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
                      setState(() {
                        Navigator.pop(context);
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
                    if (pause == false)
                      await player.pause();
                    else
                      await player.resume();
                    pause = !pause;
                    setState(() {});
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
                  await player.stop();
                  pause = true;
                  if (nextflow == false)
                    audioasset =
                        'assets/audio/' + LocaleKeys.lang.tr() + 'audioe1.mp3';
                  else
                    audioasset =
                        'assets/audio/' + LocaleKeys.lang.tr() + 'audioe15.mp3';

                  setState(() {});
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
                        disableBtn = true;
                        await player.stop();

                        audioasset = 'assets/audio/' +
                            LocaleKeys.lang.tr() +
                            'audioe15.mp3';
                        play();
                        nextflow = true;
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
            top: (MediaQuery.of(context).size.height - 166),
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

  loadAssetsPlay() async {
    String recordFilePath = await getFilePath("problem");
    if (recordFilePath != null && File(recordFilePath).existsSync()) {}
    _assetsAudioPlayer.open(
        Playlist(audios: [
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe1.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe2.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe3.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe4.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe5.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe6.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe7.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe8.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe9.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe10.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe11.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe12.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe13.mp3"),
          Audio(recordFilePath),
          Audio("assets/audio/" + LocaleKeys.lang.tr() + "audioe14.mp3"),
        ]),
        loopMode: LoopMode.single //loop the full playlist
        );

    //_assetsAudioPlayer.next();
    //_assetsAudioPlayer.prev();
    _assetsAudioPlayer.playlistPlayAtIndex(1);
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
