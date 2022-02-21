import 'dart:convert';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String audioasset = 'assets/audio/' + LocaleKeys.lang.tr() + 'audioc.mp3';
  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;

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

  bool isplaying = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    /*  ByteData bytes =
        rootBundle.load(audioasset) as ByteData; //load audio from assets
    audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    player.playBytes(audiobytes);*/
    play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height - 0,
              child: (LocaleKeys.lang.tr() == "ara")
                  ? FittedBox(
                      child: Image.asset("assets/images/araacubg.png"),
                      fit: BoxFit.fill,
                    )
                  : WebView(
                      key: const Key("webview1"),
                      debuggingEnabled: true,
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: "",
                      onWebViewCreated: (WebViewController webViewController) {
                        _webViewController = webViewController;
                        loadAsset();
                      },
                    )),
          Positioned(
            left: LocaleKeys.lang.tr() == "ara"
                ? MediaQuery.of(context).size.width - 60
                : 20,
            top: (MediaQuery.of(context).size.height - 70),
            child: Material(
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
          ),
          Positioned(
              left: LocaleKeys.lang.tr() == "ara"
                  ? 20
                  : MediaQuery.of(context).size.width - 60,
              top: (MediaQuery.of(context).size.height - 70),
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Ink.image(
                  image: (!isplaying)
                      ? const AssetImage("assets/images/btnplay.png")
                      : const AssetImage("assets/images/btnpause.png"),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8,
                  child: InkWell(onTap: () async {
                    int result = 0;

                    if (isplaying == true) {
                      result = await player.pause();
                      print("pause");
                    } else {
                      result = await player.resume();
                      print("resume");
                    }
                    if (result == 1)
                      setState(() {
                        isplaying = !isplaying;
                      });
                  }),
                ),
              ))
        ],
        /*,*/
      ),
    ));
  }

  @override
  Future<void> dispose() async {
    int result = await player.stop();
    if (result == 1) {
      setState(() {
        isplaying = true;
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
          isplaying = false;
        });
      } else {
        int result = await player.resume();
        if (result == 1) {
          isplaying = true;
        }
        print(state.toString());
      }
    }
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
