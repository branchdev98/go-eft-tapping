// @dart=2.9

import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/goefttapping.dart';

import 'package:go_eft_tapping/intro.dart';
import 'package:go_eft_tapping/localization/keys/locale_keys.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:share_plus/share_plus.dart';
import 'provider/multi_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:wakelock/wakelock.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:in_app_review/in_app_review.dart';
//import 'package:advanced_in_app_review/advanced_in_app_review.dart';

enum record_state {
  none,
  recording1,
  recording2,
  recorded1,
  recorded2,
  recorded
}
String recordFilePath;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    /*EasyLocalization(
          useOnlyLangCode: true,
          supportedLocales: [Locale('en'), Locale('sv'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          child: MyApp())*/
    const ProviderList(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO EFT Tapping',
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
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }

  //@override
  // State<MyHomePage> createState() => _MyHomePageState();
}

//AudioCache player = AudioCache();
AudioCache audioCache = AudioCache();
AudioPlayer player = AudioPlayer();
Uint8List audiobytes;

var playerState;
String audioasset;
var disableBtn = false;
var appUrl = "";
var feelingrecorded = false;
var intensityrecorded = false;
var state = record_state.none;

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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  //final String title;
// This widget is the root of your application.

  void loadplayer() {
    Future.delayed(Duration.zero, () async {
      player = new AudioPlayer();
      audioCache = new AudioCache(fixedPlayer: player, prefix: 'assets/audio/');

      player.onPlayerStateChanged.listen((PlayerState s) => {
            print('Current player state: $s'),
            Wakelock.toggle(enable: s == PlayerState.PLAYING),
            setState(() => playerState = s)
          });
    });
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
      appUrl = 'https://apps.apple.com/us/app/go-eft-tapping/id582597439';
    } else {
      appUrl =
          'https://play.google.com/store/apps/details?id=com.sarabern.go_eft_tapping';
    }

    loadplayer();
    // initPlatformState();
    /*AdvancedInAppReview()
        .setMinDaysBeforeRemind(7)
        .setMinDaysAfterInstall(2)
        .setMinLaunchTimes(2)
        .monitor();*/
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // return SafeArea(
    //   top: true,
    //  bottom: true,
    //  child:
    return Scaffold(
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 30 + 30.0,
                    ),
                    Material(
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(LocaleKeys.pagebtitle,
                            style: TextStyle(
                              fontSize:
                                  (MediaQuery.of(context).size.width / 12),
                              color: Colors.black,
                            )).tr(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 8,
                          0,
                          MediaQuery.of(context).size.width / 8,
                          0),
                      child: Material(
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(LocaleKeys.disclaimer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).size.width / 30),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )).tr(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 8,
                          0,
                          MediaQuery.of(context).size.width / 8,
                          0),
                      child: Material(
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(LocaleKeys.thesound,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).size.width / 30),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )).tr(),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      elevation: 0.0,
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
                                fit: BoxFit.fill,
                                width:
                                    MediaQuery.of(context).size.width / 4 * 3,
                                height: MediaQuery.of(context).size.height / 12,
                              ),
                              Text(
                                LocaleKeys.eftintro,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height / 40,
                                    color: Colors.white),
                              ).tr(),
                            ],
                          ),
                          onTap: () async {
                            player.stop();
                            //player.pause();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EFTIntroPage()),
                            );
                          }),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 30,
                    ),
                    IgnorePointer(
                      ignoring: disableBtn,
                      child: Container(
                        foregroundDecoration: disableBtn
                            ? const BoxDecoration(
                                color: Colors.grey,
                                backgroundBlendMode: BlendMode.lighten)
                            : null,
                        child: Material(
                          elevation: 0.0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btnblue.png"),
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width /
                                        4 *
                                        3,
                                    height:
                                        MediaQuery.of(context).size.height / 12,
                                  ),
                                  Text(
                                          (feelingrecorded == true)
                                              ? LocaleKeys.myfeelingrecorded
                                              : LocaleKeys.myfeeling,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40,
                                              color: Colors.white))
                                      .tr(),
                                ],
                              ),
                              onTap: () {
                                play("d2");
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 30,
                    ),
                    IgnorePointer(
                      ignoring: disableBtn,
                      child: Container(
                        foregroundDecoration: disableBtn
                            ? const BoxDecoration(
                                color: Colors.grey,
                                backgroundBlendMode: BlendMode.lighten)
                            : null,
                        child: Material(
                          elevation: 0.0,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: InkWell(
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.passthrough,
                                children: [
                                  Ink.image(
                                    image: const AssetImage(
                                        "assets/images/btnred.png"),
                                    fit: BoxFit.fill,
                                    width: MediaQuery.of(context).size.width /
                                        4 *
                                        3,
                                    height:
                                        MediaQuery.of(context).size.height / 12,
                                  ),
                                  Text(
                                          (intensityrecorded == true)
                                              ? LocaleKeys.theintensityrecorded
                                              : LocaleKeys.theintensity,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40,
                                              color: Colors.white))
                                      .tr(),
                                ],
                              ),
                              onTap: () {
                                play("d3");
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
                getBottomSection(context),
                getFooterSection(context),
              ])),
    );
  }

  Widget getBottomSection(context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IgnorePointer(
                  ignoring: record_state.recording1 == state,
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: InkWell(
                        child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.passthrough,
                            children: [
                              Visibility(
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: record_state.recording1 != state,
                                child: Image.asset(
                                  "assets/images/btnrecording.png",
                                  fit: BoxFit.fill,
                                  width: (state == record_state.recording1)
                                      ? MediaQuery.of(context).size.width / 3.5
                                      : 130,
                                  height: 34,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    (state == record_state.recording1) ? 0 : 20,
                                    0,
                                    0,
                                    0),
                                child: Text(
                                  (state == record_state.recording1)
                                      ? LocaleKeys.recording
                                      : LocaleKeys.recordproblem,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: (LocaleKeys.lang.tr() == "ara")
                                          ? MediaQuery.of(context).size.height /
                                              50
                                          : MediaQuery.of(context).size.height /
                                              60,
                                      fontWeight:
                                          (LocaleKeys.lang.tr() == "ara")
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color: (state == record_state.recording1)
                                          ? Colors.red
                                          : Colors.white),
                                ).tr(),
                              ),
                            ]),
                        onTap: () async {
                          startRecord("problem");
                          state = record_state.recording1;

                          disableBtn = true;
                        }),
                  ),
                ),
                Visibility(
                  maintainSize: false,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: record_state.recording1 == state,
                  child: Material(
                    //  elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image:
                                const AssetImage("assets/images/btnstop.png"),
                            fit: BoxFit.cover,
                            width: record_state.recording1 == state
                                ? MediaQuery.of(context).size.width / 10
                                : 1,
                            height: MediaQuery.of(context).size.width / 10,
                            child: InkWell(onTap: () async {
                              disableBtn = false;

                              //    AppLocalization.load(Locale('en', ''));
                              //  context.read<LocaleProvider>().setLocale(localeEN);

                              setState(() {
                                feelingrecorded = true;
                                state = record_state.recorded1;
                              });

                              var result = await stopRecord();

                              if (result == true &&
                                  intensityrecorded &&
                                  feelingrecorded) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GoEFTTappingPage()),
                                ).then((value) => {
                                      setState(() {
                                        state = record_state.none;
                                        feelingrecorded = false;
                                        intensityrecorded = false;
                                        disableBtn = false;
                                      })
                                    });
                              }
                            }),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IgnorePointer(
                  ignoring: record_state.recording2 == state,
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: InkWell(
                        child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.passthrough,
                            children: [
                              Visibility(
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: record_state.recording2 != state,
                                child: Image.asset(
                                  "assets/images/btnrecording.png",
                                  fit: BoxFit.fill,
                                  width: (state == record_state.recording2)
                                      ? MediaQuery.of(context).size.width / 3.5
                                      : 130,
                                  height: 34,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    (state == record_state.recording2) ? 0 : 20,
                                    0,
                                    0,
                                    0),
                                child: Text(
                                  (state == record_state.recording2)
                                      ? LocaleKeys.recording
                                      : LocaleKeys.recordintensity,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 1,
                                      fontSize: (LocaleKeys.lang.tr() == "ara")
                                          ? MediaQuery.of(context).size.height /
                                              50
                                          : MediaQuery.of(context).size.height /
                                              60,
                                      fontWeight:
                                          (LocaleKeys.lang.tr() == "ara")
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color: (state == record_state.recording2)
                                          ? Colors.red
                                          : Colors.white),
                                ).tr(),
                              ),
                            ]),
                        onTap: () async {
                          startRecord("intensity");
                          state = record_state.recording2;

                          disableBtn = true;
                        }),
                  ),
                ),
                Visibility(
                  maintainSize: false,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: record_state.recording2 == state,
                  child: Material(
                    //  elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    color: Colors.transparent,
                    child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.passthrough,
                        children: [
                          Ink.image(
                            image:
                                const AssetImage("assets/images/btnstop.png"),
                            fit: BoxFit.cover,
                            width: record_state.recording2 == state
                                ? MediaQuery.of(context).size.width / 10
                                : 1,
                            height: MediaQuery.of(context).size.width / 10,
                            child: InkWell(onTap: () async {
                              disableBtn = false;

                              //    AppLocalization.load(Locale('en', ''));
                              //  context.read<LocaleProvider>().setLocale(localeEN);

                              setState(() {
                                state = record_state.recorded2;
                                intensityrecorded = true;
                              });
                              var result = await stopRecord();
                              if (result == true) {
                                if (feelingrecorded == true) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GoEFTTappingPage()),
                                  ).then((value) => {
                                        setState(() {
                                          state = record_state.none;
                                          feelingrecorded = false;
                                          intensityrecorded = false;
                                          disableBtn = false;
                                        })
                                      });
                                }
                              }
                            }),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> checkPermission() async {
    await Permission.microphone.request();

    return Permission.microphone.isGranted;
  }

  void startRecord(String what) async {
    int result = 0;
    while (result == 0) {
      result = await player.stop();
    }
    player.release();

    bool hasPermission = await checkPermission();
    print("permission check");
    if (hasPermission) {
      //  statusText = "正在录音中...";
      // print(statusText);
      recordFilePath = await getFilePath(what);
      File(recordFilePath).delete();
      RecordMp3.instance.start(recordFilePath, (type) {
        //  statusText = "录音失败--->$type";
      });
      //   } else {
      //    statusText = "没有录音权限";
      //  }

    }

    /* void resumeRecord() {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "正在录音中...";
        setState(() {});
      }
    }*/

    //late String recordFilePath;
  }
}

Future<bool> stopRecord() async {
  bool s = await RecordMp3.instance.stop();
  if (s) {
    return s;
    // statusText = "录音已完成";

    //   setState(() {});
  }
  return false;
}

Future<String> getFilePath(String what) async {
  Directory storageDirectory = await getApplicationDocumentsDirectory();
  String sdPath = storageDirectory.path + "/record";
  var d = Directory(sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return sdPath + "/user" + what + ".mp3";
}

_launchURL(String toMailId, String subject, String body) async {
  var url =
      'mailto:$toMailId?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future play(String what) async {
  // final file = new File(audioasset);
  await player.stop();
  await player.release();

  String audioasset = LocaleKeys.lang.tr() + 'audio' + what + '.mp3';
  print(audioasset);
  audioCache.play(audioasset);

  if (kDebugMode) {
    print(audioasset);
  }
}

final List locale = [
  {'name': 'English ', 'locale': Locale('en')},
  {'name': 'Swedish (Svenska)', 'locale': Locale('sv')},
  {'name': 'Arabic (اَلْعَرَبِيَّةُ)', 'locale': Locale('ar')},
  {'name': 'Ukrainian (украї́нська мо́ва)', 'locale': Locale('uk')},
];

Widget getFooterSection(context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
    color: const Color(0xFF2C5D98),
    // margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Material(
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: const AssetImage("assets/images/btnlanguage.png"),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width / 15,
          height: MediaQuery.of(context).size.width / 15,
          child: InkWell(onTap: () async {
            showDialog(
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: Text(LocaleKeys.chooselanguage.tr()),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                child:
                                    (context.locale == locale[index]['locale'])
                                        ? Text(locale[index]['name'] + "   ✔️")
                                        : Text(locale[index]['name']),
                                onTap: () {
                                  print(locale[index]['locale']);
                                  if (context.locale !=
                                      locale[index]['locale']) {
                                    feelingrecorded = false;
                                    intensityrecorded = false;
                                    disableBtn = false;
                                    state = record_state.none;
                                  }
                                  context.setLocale(locale[index]['locale']);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: Colors.blue,
                            );
                          },
                          itemCount: locale.length),
                    ),
                  );
                });
          }),
        ),
      ),
      const SizedBox(width: 10),
      Material(
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: const AssetImage("assets/images/btnrate.png"),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width / 15,
          height: MediaQuery.of(context).size.width / 15,
          child: InkWell(onTap: () async {
            player.pause();
            final InAppReview inAppReview = InAppReview.instance;

            //   if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
            //  }
          }),
        ),
      ),
      const SizedBox(width: 10),
      Material(
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: const AssetImage("assets/images/fbshare.png"),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width / 15,
          height: MediaQuery.of(context).size.width / 15,
          child: InkWell(onTap: () async {
            //    url: "https://sarabern.com", msg: "share");
            await SocialSharePlugin.shareToFeedFacebookLink(
                    quote: LocaleKeys.checkout.tr(), url: appUrl)
                .catchError((e) => print("[facebook error]: " + e.toString()));
            //   } else {
            //     Fluttertoast.showToast(msg: "permission is denied");
            //   }
          }),
        ),
      ),
      const SizedBox(width: 10),
      Material(
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: const AssetImage("assets/images/shareall.png"),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width / 15,
          height: MediaQuery.of(context).size.width / 15,
          child: InkWell(onTap: () {
            //  shareFile();
            Share.share(LocaleKeys.checkout.tr() + "\n" + appUrl,
                subject: LocaleKeys.takealook.tr());
          }),
        ),
      ),
      const SizedBox(width: 10),
      Material(
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: Ink.image(
          image: const AssetImage("assets/images/btncontactus.png"),
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width / 15,
          height: MediaQuery.of(context).size.width / 15,
          child: InkWell(onTap: () async {
            player.pause();

            _launchURL('sara@goldenopportunity.se',
                LocaleKeys.ihaveaquestion.tr(), LocaleKeys.hellosara.tr());
          }),
        ),
      ),
    ]),
  );
}
