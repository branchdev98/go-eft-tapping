import 'dart:convert';

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

  var playerState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
   // return SafeArea(
     //   top: true,
     //   bottom: true,
     //   child:
     return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 30+30,
              ),
              Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(LocaleKeys.pagectitle,
                      style: TextStyle(
                        fontSize: (MediaQuery.of(context).size.width / 12),
                        color: Colors.black,
                      )).tr(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                // padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),

                //fit: StackFit.passthrough, // Just Changed this line
                //alignment: Alignment.centerRight,

                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height -
                    80 -
                    94 -
                    MediaQuery.of(context).size.width / 12,
                child: WebView(
                  key: const Key("webview1"),
                  debuggingEnabled: true,
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: "",
                  onWebViewCreated:
                      (WebViewController webViewController) async {
                    _webViewController = webViewController;
                    await loadAsset();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Row(
                  //left: 0,
                  //top: MediaQuery.of(context).size.height - 112,

                  children: [
                    SizedBox(width: 15),
                    Material(
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: const AssetImage("assets/images/btnhome.png"),
                        fit: BoxFit.contain,
                        //  padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                        width: MediaQuery.of(context).size.width / 8,
                        height: 70,
                        child: InkWell(onTap: () {
                          //int result = await player.stop();
                          //  if (result == 1) {
                          Navigator.pop(context);
                          // }
                        }),
                      ),
                    ),
                  ],
                ) /*,*/
                ,
              )
            ],
          ),
        );
  }

  @override
  Future<void> dispose() async {
    print("Back To old Screen");
    super.dispose();
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
