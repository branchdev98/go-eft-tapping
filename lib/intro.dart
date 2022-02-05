import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'localization/keys/locale_keys.g.dart';

class EFTIntroPage extends StatefulWidget {
  //const EFTIntroPage({Key? key}) : super(key: key);
  late WebViewController _webViewController;
  String audioasset = "assets/audio/audiob.mp3";
  AudioPlayer player = AudioPlayer();
  late Uint8List audiobytes;
  Future play() async {
    final result = await player.play(audioasset);
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
          Container(
              height: MediaQuery.of(context).size.height - 20,
              child: WebView(
                key: Key("webview1"),
                debuggingEnabled: true,
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: "",
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  loadAsset();
                },
              )),
          Positioned(
            left: 20,
            top: (MediaQuery.of(context).size.height - 100),
            child: Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Ink.image(
                image: AssetImage("assets/images/btnhome.png"),
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                child: InkWell(onTap: () {
                  Navigator.pop(context);
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
    String fileHtmlContents = await rootBundle
        .loadString('assets/html/' + LocaleKeys.lang.tr() + 'intro.html');
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
