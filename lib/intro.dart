import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EFTIntroPage extends StatelessWidget {
  //const EFTIntroPage({Key? key}) : super(key: key);
  late WebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height - 80,
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          )
        ]),
        /*,*/
      ),
    );
  }

  loadAsset() async {
    String fileHtmlContents =
        await rootBundle.loadString('assets/html/engintro.html');
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
