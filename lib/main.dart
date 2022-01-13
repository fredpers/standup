import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_countdown/settings.dart';
import 'package:water_countdown/theme/colortheme.dart';
import 'package:water_countdown/widgets/settingsscreen.dart';

import 'widgets/watercounter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final InAppReview inAppReview = InAppReview.instance;
  SharedPreferences preferences;

  // bool för att dölja/visa startknapp
  bool countDownStarted = false;
  ConfettiController _confettiController;
  int colorTheme = 2;

  List<String> testDevices = [];



  final BannerAd myBanner = BannerAd(
    adUnitId: AppSettings.getBannerId(),
    size: AdSize.fullBanner,
    request: AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (Ad ad) {
        print('$BannerAd loaded.');
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('$BannerAd failedToLoad: $error');
        ad.dispose();
      },
      onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
      onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
    ),
  );
  Container adContainer;
  AdWidget adWidget;

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    testDevices.add("9B6DA6FFFF197198268891BA324DB8AE");

    RequestConfiguration requestConfiguration
    = new RequestConfiguration(testDeviceIds: testDevices);
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    myBanner..load();
    adWidget = AdWidget(ad: myBanner);
    adContainer = Container(
      alignment: Alignment.center,
      child: adWidget,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
    );
    super.initState();
    confettiWidget = buildConfettiWidget();
    SharedPreferences.getInstance().then((prefs) {
      preferences = prefs;
      initDuration(prefs);
      initColorTheme(prefs);
      confettiWidget = buildConfettiWidget();
      setState(() {});
    });
  }

  void initColorTheme(SharedPreferences prefs) {
    int colorTheme = prefs.getInt('colorTheme');
    if (colorTheme == null) {
      prefs.setInt('colorTheme', ColorTheme.BLUE);
    } else {
      ColorTheme.currentSelection = colorTheme;
    }
  }

  void initDuration(SharedPreferences prefs) {
    int durationInSeconds = prefs.getInt('timeLimit');
    if (durationInSeconds == null) {
      prefs.setInt('timeLimit', new Duration(minutes: 15).inSeconds);
    } else {
      waterCountdown.resetDuration(new Duration(seconds: durationInSeconds));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  WaterCountdown waterCountdown;
  String successText = "";
  bool showSuccess = false;
  ConfettiWidget confettiWidget;

  _MyHomePageState() {
    waterCountdown = new WaterCountdown(
      // duration är hur lång nedräkningen ska vara. Går att speca t ex Duration(seconds: 10) för att testa en kort nedräkning
      duration: Duration(minutes: 15),
      // onComplete är funktionen som körs countdown har nått 00:00
      onComplete: () {
        _incrementCounter();
        countDownStarted = false;
        //Setstate bygger om appen, dvs laddar om state och uppdaterar guit
        setState(() {});
      },
      onStop: (String timeLeft) {
        _incrementCounter();
        countDownStarted = false;
        successText = timeLeft;
        showSuccess = true;
        _confettiController.play();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            confettiWidget,
            Visibility(
              visible: countDownStarted,
              // Konfettin kommer ifrån vart den här widgeten finns,
              // när det går att avbryta timern innan ska _confettiController.play(); köras
              child: Column(children: [
                InkWell(
                  onTap: () => waterCountdown.pauseCountDown(),
                  focusColor: Colors.red,
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    width: 300,
                    height: 300,
                    child: Column(
                      children: [
                        waterCountdown,
                      ],
                    ),
                  ),
                ),
                buildStopButton(context)
              ]),
            ),
            // Skapar bubblan som räknar ner, bör läggas i en InkWell så att vi kan definera en onclick osv
            buildInkWell(),
            Visibility(
              visible: showSuccess,
              child: Text(
                successText,
                style: TextStyle(color: ColorTheme.getPrimary(), fontSize: 50),
              ),
            ),

          ],
        ),
      ),
      persistentFooterButtons: [adContainer],
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Visibility(
        visible: !countDownStarted,
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ).then((value) {
              waterCountdown.resetDuration(
                  new Duration(seconds: preferences.getInt('timeLimit')));
              ColorTheme.currentSelection = preferences.getInt('colorTheme');
              _incrementCounter();
              confettiWidget = buildConfettiWidget();
              setState(() {});
            });
          }, //_showSettingsDialog,
          icon: Icon(
            Icons.settings,
            size: 50,
            color: ColorTheme.getPrimary(),
          ),
        ),
      ),
    );
  }

  ConfettiWidget buildConfettiWidget() {
    confettiWidget = null;
    return ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        maxBlastForce: 10,
        gravity: 0.002,
        emissionFrequency: 0.2,
        colors: [
          ColorTheme.getPrimaryByChoice(colorTheme),
          Colors.black12,
          Colors.blueGrey,
          Colors.amberAccent
        ],
        child: Container(
          width: 1,
          height: 1,
        ));
  }

  RaisedButton buildStopButton(BuildContext context) {
    return RaisedButton(
      color: ColorTheme.getPrimary(),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
          side: BorderSide(color: Colors.grey, width: 5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).stop_timer,
            style: TextStyle(color: Colors.white, fontSize: 35),
          ),
          Container(
            width: 1,
            height: 70,
          )
        ],
      ),
      onPressed: () {
        waterCountdown.stopCountdown();
      },
    );
  }

  Widget buildInkWell() {
    // Visibility gör så man kan gömma en widget, så la in InkWell i en som är gömd när vi räknar ner
    return Visibility(
      visible: !countDownStarted,
      child: InkWell(
        onTap: () {
          print("start button pushed");
          // Bara för att testa att den fungerar, flyttas till function som körs när man avbryter nedräkningen
          _confettiController.play();
          showSuccess = false;
          successText = "";
          countDownStarted = true;
          setState(() {
            /**
             * Due to waterCountdown being hidden until state is updated we need
             * to wait until it is visible until we try to start the countdown.
             * It's fucking hacky and will probably fail on slow devices.
             * I'll try to fix...
             */
            Future.delayed(Duration(milliseconds: 40), () {
              waterCountdown.startCountdown();
              setState(() {});
            });
          });
        },
        child: buildCenteredContainer(AppLocalizations.of(context).start),
      ),
    );
  }

  Container buildCenteredContainer(String text) {
    return Container(
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 38),
          ),
          Text(
            PrettyDuration.printDuration(waterCountdown.duration),
            style: TextStyle(color: Colors.white, fontSize: 20),
          )
        ],
      )),
      width: 290,
      height: 290,
      decoration: BoxDecoration(
        color: ColorTheme.getPrimary(),
        border: Border.all(color: Colors.grey, width: 10),
        borderRadius: BorderRadius.all(Radius.circular(300)),
      ),
    );
  }

  // Count up every time the users interact with the app.
  // After 15 increments we ask for a app review
  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    if (counter > 15 && await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
    await prefs.setInt('counter', counter);
  }
}
