import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'localization/keys/locale_keys.g.dart';

// ignore: must_be_immutable
class EFTIntroPage extends StatefulWidget {
  const EFTIntroPage({Key? key}) : super(key: key);

  @override
  State<EFTIntroPage> createState() => _EFTIntroState();
}

class _EFTIntroState extends State<EFTIntroPage> with WidgetsBindingObserver {
  late WebViewController _webViewController;

  String audioasset =  LocaleKeys.lang.tr() + 'audioc.mp3';
  AudioPlayer player = AudioPlayer();
  AudioCache audioCache = AudioCache();
  late Uint8List audiobytes;

  Future loadplayer() async {
    // final file = new File(audioasset);
    if (kIsWeb) {
      //Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      player.notificationService.startHeadlessService();
    }
      audioCache = AudioCache(prefix: 'assets/audio/');
   
     
     // ByteData bytes =
     //     await rootBundle.load(audioasset); //load audio from assets
    //  audiobytes =
     //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
       //    AudioCache audioPlayer = AudioCache();
       
        player = await audioCache.play(audioasset);
        await player.stop();
    await player.onPlayerStateChanged.listen((PlayerState s) => {
          print('Current player state: $s'),
          Wakelock.toggle(enable: s == PlayerState.PLAYING),
          setState(() => playerState = s)
        });
    //convert ByteData to Uint8List

    //await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    //final result = await player.play(file.path, isLocal: true);
    //final result = await player.play(audioasset);
    //if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  var playerState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    loadplayer().then((_) => player.resume());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          body: Container(
            child: Stack(
              fit: StackFit.loose, // Just Changed this line
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: (LocaleKeys.lang.tr() == "ara")
                        ? /*FittedBox(
                            child: Image.asset("assets/images/araacubg.png"),
                            fit: BoxFit.fill,
                          )*/
                        SafeArea(
                            top: true,
                            bottom: true,
                            child: Scaffold(
                                body: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/background.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Material(
                                            clipBehavior: Clip.hardEdge,
                                            color: Colors.transparent,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                  LocaleKeys.goefttapping,
                                                  style: TextStyle(
                                                    fontSize:
                                                        (MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            10),
                                                    color: Colors.black,
                                                  )).tr(),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Material(
                                                clipBehavior: Clip.hardEdge,
                                                color: Colors.transparent,
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child:
                                                      Text(LocaleKeys.copyright,
                                                          style: TextStyle(
                                                            fontSize:
                                                                (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    25),
                                                            color: Colors.black,
                                                          )).tr(),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Material(
                                        clipBehavior: Clip.hardEdge,
                                        color: Colors.transparent,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(LocaleKeys.thesound,
                                              style: TextStyle(
                                                fontSize:
                                                    (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        32),
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
                                            width: math.min(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                1.4,
                                            height: math.min(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                1.1,
                                          ),
                                          SizedBox(
                                            height: 100,
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 30,
                                        left: (LocaleKeys.lang.tr() == "ara")
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                math.min(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height) /
                                                    2.7
                                            : 20,
                                        child: Text(
                                          LocaleKeys.acupoints2,
                                          style: TextStyle(
                                              height: (LocaleKeys.lang.tr() ==
                                                      "ara")
                                                  ? 1.1
                                                  : 1.5,
                                              fontSize: math.min(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height) /
                                                  (LocaleKeys.lang.tr() == "ara"
                                                      ? 20
                                                      : 25),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ).tr(),
                                      ),
                                      Positioned(
                                        top: math.min(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height,
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                1.1 +
                                            ((LocaleKeys.lang.tr() == "ara")
                                                ? 5
                                                : 5),
                                        left: (LocaleKeys.lang.tr() == "ara")
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                math.min(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width) /
                                                    1.5 -
                                                10
                                            : math.min(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width) /
                                                    1.5 -
                                                20,
                                        child: Text(
                                          LocaleKeys.acupoints,
                                          style: TextStyle(
                                              height: 1.0,
                                              fontSize: math.min(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height) /
                                                  26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ).tr(),
                                      ),
                                    ],
                                  ),

                                  /* add child content here */
                                ],
                              ),
                            )))
                        : WebView(
                            key: const Key("webview1"),
                            debuggingEnabled: true,
                            javascriptMode: JavascriptMode.unrestricted,
                            initialUrl: "",
                            onWebViewCreated:
                                (WebViewController webViewController) async {
                              _webViewController = webViewController;
                              await loadAsset();
                            },
                          )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: const AssetImage("assets/images/btnhome.png"),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 8,
                        height: MediaQuery.of(context).size.width / 8,
                        child: InkWell(onTap: () async {
                          int result = await player.stop();
                          if (result == 1) {
                            Navigator.pop(context);
                          }
                        }),
                      ),
                    ),
                    Material(
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: playerState == PlayerState.PLAYING
                            ? const AssetImage("assets/images/btnpause.png")
                            : const AssetImage("assets/images/btnplay.png"),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 8,
                        height: MediaQuery.of(context).size.width / 8,
                        child: InkWell(onTap: () {
                          if (playerState == PlayerState.PLAYING) {
                            player.pause();
                          } else {
                            player.resume();
                          }
                        }),
                      ),
                    ),
                  ],
                )
              ],
            ),

            /*,*/
          ),
        ));
  }

  @override
  Future<void> dispose() async {
    player.stop();

    print("Back To old Screen");
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      //stop your audio player
      player.pause();
    }
    if (state == AppLifecycleState.resumed) {
      //  player.resume();
    }
  }

  loadAsset() async {
    String fileHtmlContents = await rootBundle
        .loadString('assets/html/' + LocaleKeys.lang.tr() + 'intro.html');
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
