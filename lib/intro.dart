import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EFTIntroPage extends StatelessWidget {
  const EFTIntroPage({Key? key}) : super(key: key);

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
                  initialUrl: "https://flutter.dev/")),
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
}
