// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:go_eft_tapping/intro.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:go_eft_tapping/locale/app_localization.dart';

import 'package:go_eft_tapping/localization/keys/locale_keys.g.dart';
import 'package:go_eft_tapping/manager/localization_manager.dart';
import 'package:go_eft_tapping/youreft.dart';
import 'provider/multi_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

//import 'package:share/share.dart';
// @dart=2.9
void main() {
  runApp(
    const ProviderList(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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

class _MyHomePageState extends State<MyHomePage> {
  int currentpos = 0;
  String currentpostlabel = "00:00";
  String maxpostlabel = "00:00";
  int maxduration = 40;

  String audioasset = "assets/audio/audiob.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    //return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List

      player.onDurationChanged.listen((Duration d) {
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
    });
    super.initState();
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
                    image: isplaying
                        ? const AssetImage("assets/images/pausebutton.png")
                        : const AssetImage("assets/images/infobutton.png"),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    child: InkWell(
                      onTap: () async {
                        if (!isplaying && !audioplayed) {
                          int result = await player.playBytes(audiobytes);
                          if (result == 1) {
                            //play success
                            setState(() {
                              isplaying = true;
                              audioplayed = true;
                            });
                          } else {
                            if (kDebugMode) {
                              print("Error while playing audio.");
                            }
                          }
                        } else if (audioplayed && !isplaying) {
                          int result = await player.resume();
                          if (result == 1) {
                            //resume success
                            setState(() {
                              isplaying = true;
                              audioplayed = true;
                            });
                          } else {
                            if (kDebugMode) {
                              print("Error on resume audio.");
                            }
                          }
                        } else {
                          int result = await player.pause();
                          if (result == 1) {
                            //pause success
                            setState(() {
                              isplaying = false;
                            });
                          } else {
                            if (kDebugMode) {
                              print("Error on pause audio.");
                            }
                          }
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

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget getFooterSection() {
    return Stack(children: <Widget>[
      Image.asset(
        "assets/images/bottombg.png",
        fit: BoxFit.fill,
        width: MediaQuery.of(context).size.width,
        height: 70,
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
                        if (await canLaunch("https://www.facebook.com")) {
                          await launch("https://www.facebook.com");
                        } else {
                          throw 'Could not launch https://www.facebook.com';
                        }
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      body: ListView(
        children: [
          getTitleSection(),
          Stack(alignment: Alignment.bottomCenter, children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 85,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/background.png"),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  (MediaQuery.of(context).size.width / 10) * 3.6,
              top: 10,
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
              top: 5,
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
              top: (MediaQuery.of(context).size.width / 10) + 20,
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
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 0.7,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: InkWell(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      Ink.image(
                        image: const AssetImage("assets/images/bluebutton.png"),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 4 * 3,
                        height: MediaQuery.of(context).size.width / 6,
                      ),
                      Text(
                        LocaleKeys.eftintro,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 15,
                            color: Colors.white),
                      ).tr(),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EFTIntroPage()),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 1.2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: InkWell(
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.passthrough,
                      children: [
                        Ink.image(
                          image:
                              const AssetImage("assets/images/greenbutton.png"),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width / 4 * 3,
                          height: MediaQuery.of(context).size.width / 6,
                        ),
                        Text(LocaleKeys.youreft,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 15,
                                    color: Colors.white))
                            .tr(),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const YourEFT()),
                      );
                    }),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 1.7,
              child: Material(
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
                          width: MediaQuery.of(context).size.width / 4 * 3,
                          height: MediaQuery.of(context).size.width / 6,
                        ),
                        Text(LocaleKeys.contactme,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 15,
                                    color: Colors.white))
                            .tr(),
                      ],
                    ),
                    onTap: () {
                      _launchURL(
                          'sara@goldenopportunity.se',
                          '[From GO EFT Tapping App] I have a question',
                          'Hello Sara! ');
                    }),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: const AssetImage("assets/images/btnenglish.png"),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: MediaQuery.of(context).size.width / 6,
                      child: InkWell(onTap: () async {
                        //    AppLocalization.load(Locale('en', ''));
                        //  context.read<LocaleProvider>().setLocale(localeEN);
                        await context
                            .setLocale(LocalizationManager.instance.enUSLocale);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2 +
                  MediaQuery.of(context).size.width / 4 * 0.98,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: const AssetImage("assets/images/btnswedish.png"),
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: MediaQuery.of(context).size.width / 6,
                      child: InkWell(onTap: () async {
                        await context
                            .setLocale(LocalizationManager.instance.svSELocale);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  MediaQuery.of(context).size.width / 4 * 3 / 2 +
                  MediaQuery.of(context).size.width / 4 * 2,
              top: MediaQuery.of(context).size.height / 4 * 2.2,
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Ink.image(
                      image: const AssetImage("assets/images/btnarabic.png"),
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width / 4 * 0.95,
                      height: MediaQuery.of(context).size.width / 6,
                      child: InkWell(onTap: () async {
                        await context
                            .setLocale(LocalizationManager.instance.arAELocale);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            getFooterSection(),
          ])
        ],
      ),
    );
  }
}
