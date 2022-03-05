// @dart=2.9

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/intro.dart';
import 'package:go_eft_tapping/localization/keys/locale_keys.g.dart';
import 'package:go_eft_tapping/manager/localization_manager.dart';
import 'package:go_eft_tapping/youreft.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'provider/multi_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    const ProviderList(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: true,
      home: const MyHomePage(title: 'GO EFT Tapping'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//AudioCache player = AudioCache();
AudioCache audioCache = AudioCache();
AudioPlayer player = AudioPlayer();
Uint8List audiobytes;
var currentpos = 0;
String currentpostlabel = "00:00";
String maxpostlabel = "00:00";
int maxduration = 40;
var playerState;

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String audioasset = "assets/audio/" + LocaleKeys.lang.tr() + "audiob.mp3";

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    //return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) {
      //Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      player.notificationService?.startHeadlessService();
    }
      audioCache = AudioCache(prefix: 'assets/audio/');
    Future.delayed(Duration.zero, () async {
      audioasset =  LocaleKeys.lang.tr() + "audiob.mp3";
     // ByteData bytes =
     //     await rootBundle.load(audioasset); //load audio from assets
    //  audiobytes =
     //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
       //    AudioCache audioPlayer = AudioCache();
       
        player = await audioCache.play(audioasset);
        
        //await player.pause();
      //convert ByteData to Uint8List
      //  AudioPlayer player1;

      player.onDurationChanged.listen((Duration d) {
        print("durationchanged");
        //get the duration of audio
        maxduration = d.inMilliseconds;
        int sseconds = Duration(milliseconds: maxduration).inSeconds;

        final total = Duration(seconds: sseconds);

        maxpostlabel = _printDuration(total);
        if (kDebugMode) {
          print(_printDuration(total));
        }
        player.stop();
        setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        //    int shours = Duration(milliseconds: currentpos).inHours;
        //     int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        //  int rhours = shours;
        //  int rminutes = sminutes - (shours * 60);
        //  int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        final now = Duration(seconds: sseconds);

        currentpostlabel = _printDuration(now);

        setState(() {
          //refresh the UI
        });
      });

      player.onPlayerStateChanged.listen((PlayerState s) => {
            print('Current player state: $s'),
            Wakelock.toggle(enable: s == PlayerState.PLAYING),
            setState(() => playerState = s)
          });
    });
    //   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return SafeArea(
      top: true,
      bottom: true,
      child: Scaffold(
          body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/background.png"),
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        getTitleSection(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              clipBehavior: Clip.hardEdge,
                              color: Colors.transparent,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(LocaleKeys.goefttapping,
                                    style: TextStyle(
                                      fontSize:
                                          (MediaQuery.of(context).size.width /
                                              10),
                                      color: Colors.black,
                                    )).tr(),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Material(
                                  clipBehavior: Clip.hardEdge,
                                  color: Colors.transparent,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(LocaleKeys.copyright,
                                        style: TextStyle(
                                          fontSize: (MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25),
                                          color: Colors.black,
                                        )).tr(),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
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
                                      (MediaQuery.of(context).size.width / 32),
                                  color: Colors.black,
                                )).tr(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Material(
                          elevation: 4.0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/bluebutton.png"),
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width /
                                        4 *
                                        3,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                  Text(
                                    LocaleKeys.eftintro,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                15,
                                        color: Colors.white),
                                  ).tr(),
                                ],
                              ),
                              onTap: () async {
                                player.pause();
                                //player.pause();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EFTIntroPage()),
                                );
                              }),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 20,
                        ),
                        Material(
                          elevation: 4.0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btngreen.png"),
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width /
                                        4 *
                                        3,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                  Text(LocaleKeys.youreft,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                              color: Colors.white))
                                      .tr(),
                                ],
                              ),
                              onTap: () {
                                player.pause();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const YourEFT()),
                                );
                              }),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 20,
                        ),
                        Material(
                          elevation: 4.0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/orangecontactbutton.png"),
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width /
                                        4 *
                                        3,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                  ),
                                  Text(LocaleKeys.contactme,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                              color: Colors.white))
                                      .tr(),
                                ],
                              ),
                              onTap: () {
                                player.pause();

                                _launchURL(
                                    'sara@goldenopportunity.se',
                                    LocaleKeys.ihaveaquestion.tr(),
                                    LocaleKeys.hellosara.tr());
                              }),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              elevation: 4.0,
                              clipBehavior: Clip.antiAlias,
                              color: Colors.transparent,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btnenglish.png"),
                                    fit: BoxFit.cover,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                    child: InkWell(onTap: () {
                                      player.stop();

                                      context.setLocale(LocalizationManager
                                          .instance.enUSLocale);
                                      initState();
                                    }
                                        //    AppLocalization.load(Locale('en', ''));
                                        //  context.read<LocaleProvider>().setLocale(localeEN);
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              elevation: 4.0,
                              clipBehavior: Clip.hardEdge,
                              color: Colors.transparent,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btnswedish.png"),
                                    fit: BoxFit.fitWidth,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                    child: InkWell(onTap: () {
                                      player.stop();

                                      context.setLocale(LocalizationManager
                                          .instance.svSELocale);
                                      initState();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              elevation: 4.0,
                              clipBehavior: Clip.hardEdge,
                              color: Colors.transparent,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btnarabic.png"),
                                    fit: BoxFit.fitWidth,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height:
                                        MediaQuery.of(context).size.width / 6,
                                    child: InkWell(onTap: () {
                                      player.stop();

                                      context.setLocale(LocalizationManager
                                          .instance.arAELocale);
                                      initState();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    getFooterSection(context),
                  ]))),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      //stop your audio player
      player.pause();
    }
    if (state == AppLifecycleState.resumed) {
      //player.resume();
    }
  }

  @override
  Future<void> dispose() async {
    player.stop();

    print("Back To old Screen");
    super.dispose();
  }

  Widget getTitleSection() {
    return Container(
      padding: const EdgeInsets.all(1),
      color: Colors.black,
      child: Row(
        children: [
          Material(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: playerState == PlayerState.PLAYING
                        ? const AssetImage("assets/images/btnpause.png")
                        : playerState == PlayerState.PAUSED
                            ? const AssetImage("assets/images/btnplay.png")
                            : const AssetImage("assets/images/infobutton.png"),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    child: InkWell(
                      onTap: () async {
                        if (playerState == PlayerState.PAUSED) {
                          int result = await player.resume();
                        //  if (result != 1) player.playBytes(audiobytes);
                        } else if (playerState == PlayerState.PLAYING) {
                          player.pause();
                        } else {
                       /*   AudioCache audioPlayer = AudioCache();
                          player = await audioPlayer.play('audio/engaudiob.mp3');
                           player.onDurationChanged.listen((Duration d) {
                              print("durationchanged");
                              //get the duration of audio
                              maxduration = d.inMilliseconds;
                              int sseconds = Duration(milliseconds: maxduration).inSeconds;

                              final total = Duration(seconds: sseconds);

                              maxpostlabel = _printDuration(total);
                              if (kDebugMode) {
                                print(_printDuration(total));
                              }

                              setState(() {});
                            });
                            */
                            player.resume();
                          // player.play('engaudiob.mp3');
                          //player.playBytes(audiobytes);
                        }
                      },
                    ),
                  ),
                ]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Slider(
                  value: double.parse(currentpos.toString()),
                  activeColor: Colors.blue[200],
                  inactiveColor: Colors.white,
                  min: 0,
                  max: double.parse(maxduration.toString()),
                  divisions: maxduration,
                  label: currentpostlabel,
                  onChanged: (double value) async {
                    int seekval = value.round();
                    int result =
                        await player.seek(Duration(milliseconds: seekval));
                    if (result == 1) {
                      //seek successful
                      currentpos = seekval;
                    } else {
                      if (kDebugMode) {
                        print("Seek unsuccessful.");
                      }
                    }
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(currentpostlabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        )),
                    const SizedBox(width: 10), // use Spacer
                    Text(maxpostlabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        )),
                    const SizedBox(width: 20),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> getFilePath() async {
  final bytes = await rootBundle.load('assets/images/bluebutton.png');
  final list = bytes.buffer.asUint8List();

  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/image.jpg').create();
  file.writeAsBytesSync(list);
  return file.path;
}

_launchURL(String toMailId, String subject, String body) async {
  var url = 'mailto:$toMailId?subject=$subject&body=$body';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget getFooterSection(context) {
  return Stack(children: <Widget>[
    Image.asset(
      "assets/images/bottombg.png",
      fit: BoxFit.fill,
      width: MediaQuery.of(context).size.width,
      height: 75,
    ),
    Container(
        margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Row(children: [
          Material(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: const AssetImage("assets/images/fbshare.png"),
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    child: InkWell(onTap: () async {
                      //    url: "https://sarabern.com", msg: "share");
                      await SocialSharePlugin.shareToFeedFacebookLink(
                              quote: 'check out GO EFT TAPPING app!',
                              url:
                                  'https://apps.apple.com/us/app/go-eft-tapping/id582597439')
                          .catchError((e) =>
                              print("[facebook error]: " + e.toString()));
                      //   } else {
                      //     Fluttertoast.showToast(msg: "permission is denied");
                      //   }
                    }),
                  ),
                ]),
          ),
          const SizedBox(width: 10),
          Material(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  Ink.image(
                    image: const AssetImage("assets/images/shareall.png"),
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    child: InkWell(onTap: () {
                      //  shareFile();
                      Share.share('check out my website https://sarabern.com',
                          subject: 'Look what I made!');
                    }),
                  ),
                ]),
          ),
          const SizedBox(width: 10),
          Material(
            elevation: 4.0,
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: const Text(LocaleKeys.sharingiscaring,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  )).tr(),
            ),
          ),
        ])),
  ]);
}
