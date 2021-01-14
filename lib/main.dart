import 'package:confetti/confetti.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/watercounter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
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
  // bool för att dölja/visa startknapp
  bool countDownStarted = false;
  ConfettiController _confettiController;

  /* Om vi vill slå på ads sen är det bara att kommentera ut den här sektionen
   + lägga till Id'n.
  BannerAd myBanner = BannerAd(
    adUnitId: AppSettings.getBannerId(),
    size: AdSize.smartBanner,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );*/

  @override
  void initState() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    /* Använd för att visa banner ads
    FirebaseAdMob.instance.initialize(appId: AppSettings.getAppId());
    myBanner
      ..load()
      ..show(anchorType: AnchorType.bottom);
      */
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  WaterCountdown waterCountdown;
  String successText = "";
  bool showSuccess = false;

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
            // Skapar bubblan som räknar ner, bör läggas i en InkWell så att vi kan definera en onclick osv
            ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 10,
                gravity: 0.002,
                emissionFrequency: 0.2,
                colors: [
                  Colors.blueAccent,
                  Colors.black12,
                  Colors.blueGrey,
                  Colors.amberAccent
                ],
                child: Container(
                  width: 1,
                  height: 1,
                )),
            buildInkWell(),
            Visibility(
              visible: showSuccess,
              child: Text(
                successText,
                style: TextStyle(color: Color(0xFF6AA0E1), fontSize: 50),
              ),
            ),
            Visibility(
              visible: countDownStarted,
              // Konfettin kommer ifrån vart den här widgeten finns,
              // när det går att avbryta timern innan ska _confettiController.play(); köras
              child: Container(
                  child: Column(
                children: [
                  waterCountdown,
                  Container(
                    width: 1,
                    height: 150,
                  ),
                  buildStopButton(context),
                ],
              )),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Visibility(
        visible: !countDownStarted,
        child: IconButton(
          onPressed: () {
            showSettingsDialog(context);}, //_showSettingsDialog,
          icon: Icon(
            Icons.settings,
            size: 50,
            color: Color(0xFF6AA0E1),
          ),
        ),
      ),
    );
  }

  RaisedButton buildStopButton(BuildContext context) {
    return RaisedButton(
      color: Color(0xFF6AA0E1),
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
        color: Color(0xFF6AA0E1),
        border: Border.all(color: Colors.grey, width: 10),
        borderRadius: BorderRadius.all(Radius.circular(300)),
      ),
    );
  }

  void showSettingsDialog(BuildContext context) {
    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        NumberPickerColumn(
            begin: 0,
            end: 59,
            suffix: Text(AppLocalizations.of(context).minutes),
            initValue: 15),
        NumberPickerColumn(
            begin: 0,
            end: 59,
            suffix: Text(AppLocalizations.of(context).seconds),
            jump: 5,
            initValue: 0),
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: AppLocalizations.of(context).ok,
      cancelText: AppLocalizations.of(context).cancel,
      title: Text(AppLocalizations.of(context).select_duration),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        _incrementCounter();
        // Set the duration of the countdown
        Duration _duration = Duration(
            minutes: picker.getSelectedValues()[0],
            seconds: picker.getSelectedValues()[1]);
        if (_duration.inSeconds != 0) {
          waterCountdown.resetDuration(_duration);
          setState(() {});
        }
      },
    ).showDialog(context);
  }
  // Count up every time the users interact with the app.
  // After 15 increments we ask for a app review
  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    print('Pressed $counter times.');
    if (counter>15 && await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
    await prefs.setInt('counter', counter);
  }
}
