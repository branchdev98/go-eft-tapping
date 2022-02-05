import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'localization/keys/locale_keys.g.dart';

class EFTIntroPage extends StatelessWidget {
  //const EFTIntroPage({Key? key}) : super(key: key);
  late WebViewController _webViewController;
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
}
