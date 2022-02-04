import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EFTIntroPage extends StatelessWidget {
  const EFTIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: <Widget>[
          Text("hiiiiiiiiiiiii "),
          Text("hiiiiiiiiiiiii "),
          Container(
              height: 300,
              child: WebView(
                  key: Key("webview1"),
                  debuggingEnabled: true,
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: "https://flutter.dev/")),
          Text("hiiiiiiiiiiiii "),
          Text("hiiiiiiiiiiiii "),
        ]),
        /*ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),*/
      ),
    );
  }
}
