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

class _EFTIntroState extends State<EFTIntroPage> {
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

  void initState() {
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
        child: Stack(children: <Widget>[
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
                ? MediaQuery.of(context).size.width - 120
                : 20,
            top: (MediaQuery.of(context).size.height - 100),
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage("assets/images/btnhome.png"),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width / 6,
                height: MediaQuery.of(context).size.width / 6,
                child: InkWell(onTap: () async {
                  int result = await player.stop();
                  if (result == 1) {
                    Navigator.pop(context);
                  }
                }),
              ),
            ),
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
