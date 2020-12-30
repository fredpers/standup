import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'widgets/watercounter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // bool för att dölja/visa startknapp
  bool countDownStarted = false;

  //lägger till AudioCache
  //final player = AudioCache();

  WaterCountdown waterCountdown;

  _MyHomePageState() {
    waterCountdown = new WaterCountdown(
      // duration är hur lång nedräkningen ska vara. Går att speca t ex Duration(seconds: 10) för att testa en kort nedräkning
      duration: Duration(seconds: 10),
      // onComplete är funktionen som körs countdown har nått 00:00
      onComplete: () {
        print("done");
        //TODO Spela upp ett "mötet är slut"-ljud
        // Guide via https://stackoverflow.com/questions/56377942/flutter-play-sound-on-button-press
        //player.play('audio/time_out.mp3');
        countDownStarted = false;
        //Setstate bygger om appen, dvs laddar om state och uppdaterar guit
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      //Tog bort Appbar så den är mer clean, men kanske ska ha kvar den
        /*appBar: AppBar(
          title: Text(widget.title),
        ),*/
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Skapar bubblan som räknar ner, bör läggas i en InkWell så att vi kan definera en onclick osv
              waterCountdown,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: buildInkWell()
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget buildInkWell() {
    // Visibility gör så man kan gömma en widget, så la in InkWell i en som är gömd när vi räknar ner
    return Visibility(
        visible: !countDownStarted,
        child: InkWell(
            onTap: () {
              waterCountdown.startCountdown();
              countDownStarted = true;
              setState(() {});
            },
            child: Center(
              heightFactor: 2.7,
              child: Container(
                child: Center(
                    child: Text(
                  "Start",
                  style: TextStyle(color: Colors.white, fontSize: 38),
                )),
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    border: Border.all(
                      color: Colors.grey,
                      width: 10
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(300))),
              ),
            )
        )
    );
  }
}
