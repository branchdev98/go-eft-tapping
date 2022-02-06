import 'dart:convert';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'localization/keys/locale_keys.g.dart';

class YourEFTPage extends StatelessWidget {
//  const EFTIntroPage({Key? key}) : super(key: key);

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
        body: ListView(children: [
      Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 20,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: new AssetImage("assets/images/background.png"),
              ),
            ),
          ),
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
                (MediaQuery.of(context).size.width / 10) * 3.8,
            top: (MediaQuery.of(context).size.width / 10) + 50,
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
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 0.9,
            child: Material(
              elevation: 4.0,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: AssetImage("assets/images/bluebutton.png"),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 4 * 3,
                    height: MediaQuery.of(context).size.width / 6,
                    // child: InkWell(onTap: () {
                    //   Navigator.push(
                    //    context,
                    //   MaterialPageRoute(
                    //     builder: (context) => EFTIntroPage()),
                    //   );
                    //  }),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Text(
                          LocaleKeys.ihaveheard,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 30,
                              color: Colors.white),
                        ).tr(),
                        onTap: () {
                          //  Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => EFTIntroPage()),
                          //  );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 1.4,
            child: Material(
              elevation: 4.0,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: AssetImage("assets/images/greenbutton.png"),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 4 * 3,
                    height: MediaQuery.of(context).size.width / 6,
                    child: InkWell(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => YourEFTPage()),
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(LocaleKeys.myfeeling,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 20,
                                  color: Colors.white))
                          .tr(),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 1.9,
            child: Material(
              elevation: 4.0,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: AssetImage("assets/images/orangecontactbutton.png"),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 4 * 3,
                    height: MediaQuery.of(context).size.width / 6,
                    child: InkWell(onTap: () {}),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(LocaleKeys.contactme,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 15,
                                  color: Colors.white))
                          .tr(),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 -
                MediaQuery.of(context).size.width / 4 * 3 / 2,
            top: MediaQuery.of(context).size.height / 4 * 2.5,
            child: Material(
              elevation: 4.0,
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: AssetImage("assets/images/btnenglish.png"),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width / 4 * 3,
                    height: MediaQuery.of(context).size.width / 6,
                    child: InkWell(onTap: () {
                      //    AppLocalization.load(Locale('en', ''));
                      //  context.read<LocaleProvider>().setLocale(localeEN);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ]));
  }

  loadAsset() async {
    play();
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
